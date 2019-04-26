//
//  TestTransactionConsumptionCanceller.swift
//  POSClientTests
//
//  Created by Mederic Petit on 4/2/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient
import UIKit

class TestTransactionConsumptionCanceller {
    var callbackClosure: TransactionConsumption.RetrieveRequestCallback!
    var consumption: TransactionConsumption?

    func getSuccess(withConsumption consumption: TransactionConsumption) {
        self.callbackClosure?(OmiseGO.Response.success(consumption))
    }

    func getFailure() {
        self.callbackClosure?(OmiseGO.Response.failure(.unexpected(message: "test")))
    }
}

extension TestTransactionConsumptionCanceller: TransactionConsumptionCancellerProtocol {
    func cancel(consumption: TransactionConsumption?,
                callback: @escaping TransactionConsumption.RetrieveRequestCallback) -> TransactionConsumption.RetrieveRequest? {
        self.consumption = consumption
        self.callbackClosure = callback
        return nil
    }
}
