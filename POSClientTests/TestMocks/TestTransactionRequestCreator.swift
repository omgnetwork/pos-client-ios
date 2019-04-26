//
//  TestTransactionRequestCreator.swift
//  POSClientTests
//
//  Created by Mederic Petit on 19/10/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient
import UIKit

class TestTransactionRequestCreator {
    var didCallCreate = false

    var createCompletionClosures: [TransactionRequest.RetrieveRequestCallback] = []

    func createSuccess(withRequest request: TransactionRequest) {
        self.createCompletionClosures.first?(OmiseGO.Response.success(request))
        _ = self.createCompletionClosures.removeFirst()
    }

    func createFailed(withError error: OMGError) {
        self.createCompletionClosures.first?(OmiseGO.Response.failure(error))
        _ = self.createCompletionClosures.removeFirst()
    }
}

extension TestTransactionRequestCreator: TransactionRequestCreatorProtocol {
    func create(withParams _: TransactionRequestCreateParams,
                callback: @escaping TransactionRequest.RetrieveRequestCallback) -> TransactionRequest.RetrieveRequest? {
        self.didCallCreate = true
        self.createCompletionClosures.append(callback)
        return nil
    }
}
