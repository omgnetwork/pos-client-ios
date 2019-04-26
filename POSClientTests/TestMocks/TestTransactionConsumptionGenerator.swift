//
//  TestTransactionConsumptionGenerator.swift
//  POSClientTests
//
//  Created by Mederic Petit on 4/2/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient
import UIKit

class TestTransactionConsumptionGenerator {
    var consumedCalledWithParams: TransactionConsumptionParams?
    var callbackClosure: TransactionConsumption.RetrieveRequestCallback!

    func success(withConsumption consumption: TransactionConsumption) {
        self.callbackClosure?(OmiseGO.Response.success(consumption))
    }

    func failure(withError error: OMGError) {
        self.callbackClosure?(OmiseGO.Response.failure(error))
    }
}

extension TestTransactionConsumptionGenerator: TransactionConsumptionGeneratorProtocol {
    func consume(withParams params: TransactionConsumptionParams,
                 callback: @escaping TransactionConsumption.RetrieveRequestCallback) -> TransactionConsumption.RetrieveRequest? {
        self.consumedCalledWithParams = params
        self.callbackClosure = callback
        return nil
    }
}
