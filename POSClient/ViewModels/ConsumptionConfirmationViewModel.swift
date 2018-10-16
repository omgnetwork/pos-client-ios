//
//  ConsumptionConfirmationViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 16/10/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class ConsumptionConfirmationViewModel: BaseViewModel, ConsumptionConfirmationViewModelProtocol {
    // Delegate closures
    var onSuccessApprove: SuccessClosure?
    var onFailApprove: FailureClosure?
    var onSuccessReject: SuccessClosure?
    var onFailReject: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    let title: String
    let direction: String
    let amountDisplay: String
    let confirmButtonTitle = "consumption_confirmation.button.confirm".localized()
    let rejectButtonTitle = "consumption_confirmation.button.reject".localized()
    var accountName: String = "-"

    private var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    private let consumption: TransactionConsumption
    private let sessionManager: SessionManagerProtocol

    required init(sessionManager: SessionManagerProtocol = SessionManager.shared,
                  consumption: TransactionConsumption) {
        self.sessionManager = sessionManager
        self.title = "consumption_confirmation.send".localized()
        self.direction = "consumption_confirmation.to".localized()
        self.consumption = consumption
        self.accountName = consumption.account?.name ?? "-"
        let formattedAmount = OMGNumberFormatter().string(from: consumption.estimatedRequestAmount,
                                                          subunitToUnit: consumption.transactionRequest.token.subUnitToUnit)
        self.amountDisplay = "\(formattedAmount) \(consumption.transactionRequest.token.symbol)"
        super.init()
    }

    func approve() {
        self.isLoading = true
        self.consumption.approve(using: self.sessionManager.httpClient) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.onSuccessApprove?()
            case let .fail(error: error):
                self?.onFailApprove?(.omiseGO(error: error))
            }
        }
    }

    func reject() {
        self.isLoading = true
        self.consumption.reject(using: self.sessionManager.httpClient) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.onSuccessReject?()
            case let .fail(error: error):
                self?.onFailReject?(.omiseGO(error: error))
            }
        }
    }
}
