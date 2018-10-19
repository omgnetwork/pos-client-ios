//
//  TransactionRequestBuilder.swift
//  POSClient
//
//  Created by Mederic Petit on 12/10/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

protocol TransactionRequestBuilderProtocol {
    func build(withTokenId tokenId: String,
               onSuccess: @escaping ObjectClosure<Data>,
               onFailure: @escaping FailureClosure)
}

class TransactionRequestBuilder: TransactionRequestBuilderProtocol {
    private let sessionManager: SessionManagerProtocol
    private let transactionRequestCreator: TransactionRequestCreatorProtocol

    init(sessionManager: SessionManagerProtocol = SessionManager.shared,
         transactionRequestCreator: TransactionRequestCreatorProtocol = TransactionRequestCreator()) {
        self.sessionManager = sessionManager
        self.transactionRequestCreator = transactionRequestCreator
    }

    func build(withTokenId tokenId: String,
               onSuccess: @escaping ObjectClosure<Data>,
               onFailure: @escaping FailureClosure) {
        if let existingString = UserDefaultsWrapper().getData(forKey: .transactionRequestsQRString) {
            onSuccess(existingString)
            return
        }
        var raisedError: OMGError?
        var receiveId: String?
        var topupId: String?
        let group = DispatchGroup()
        group.enter()
        self.buildReceive(withTokenId: tokenId) { result in
            switch result {
            case let .success(data: receiveTR): receiveId = receiveTR.formattedId
            case let .fail(error: error): raisedError = error
            }
            group.leave()
        }
        group.enter()
        self.buildTopup(withTokenId: tokenId) { result in
            switch result {
            case let .success(data: topupTR): topupId = topupTR.formattedId
            case let .fail(error: error): raisedError = error
            }
            group.leave()
        }
        dispatchGlobal {
            group.wait()
            dispatchMain {
                if let error = raisedError {
                    onFailure(.omiseGO(error: error))
                } else if let receiveId = receiveId,
                    let topupId = topupId,
                    let data = "\(receiveId)|\(topupId)".data(using: .isoLatin1) {
                    UserDefaultsWrapper().storeData(data: data, forKey: .transactionRequestsQRString)
                    onSuccess(data)
                } else {
                    onFailure(.unexpected)
                }
            }
        }
    }

    private func buildReceive(withTokenId tokenId: String,
                              callback: @escaping TransactionRequest.RetrieveRequestCallback) {
        let receive = TransactionRequestCreateParams(type: .receive,
                                                     tokenId: tokenId,
                                                     amount: nil,
                                                     address: sessionManager.wallet!.address,
                                                     requireConfirmation: false,
                                                     allowAmountOverride: true)!
        self.transactionRequestCreator.create(withParams: receive, callback: callback)
    }

    private func buildTopup(withTokenId tokenId: String,
                            callback: @escaping TransactionRequest.RetrieveRequestCallback) {
        let topup = TransactionRequestCreateParams(type: .send,
                                                   tokenId: tokenId,
                                                   amount: nil,
                                                   address: sessionManager.wallet!.address,
                                                   requireConfirmation: true,
                                                   allowAmountOverride: true)!
        self.transactionRequestCreator.create(withParams: topup, callback: callback)
    }
}
