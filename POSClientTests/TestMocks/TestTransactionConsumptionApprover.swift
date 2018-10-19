//
//  TestTransactionConsumptionApprover.swift
//  POSClientTests
//
//  Created by Mederic Petit on 19/10/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import OmiseGO
@testable import POSClient
import UIKit

class TestTransactionConsumptionApprover {
    var isApproveCalled = false
    var isRejectCalled = false

    var approveCompletionClosure: TransactionConsumption.RetrieveRequestCallback?
    var rejectCompletionClosure: TransactionConsumption.RetrieveRequestCallback?

    func approveSuccess(withConsumption consumption: TransactionConsumption) {
        self.approveCompletionClosure?(OmiseGO.Response.success(data: consumption))
    }

    func rejectSuccess(withConsumption consumption: TransactionConsumption) {
        self.rejectCompletionClosure?(OmiseGO.Response.success(data: consumption))
    }

    func approveFailed(withError error: OMGError) {
        self.approveCompletionClosure?(OmiseGO.Response.fail(error: error))
    }

    func rejectFailed(withError error: OMGError) {
        self.rejectCompletionClosure?(OmiseGO.Response.fail(error: error))
    }
}

extension TestTransactionConsumptionApprover: TransactionConsumptionApproverProtocol {
    func approve(consumption _: TransactionConsumption, callback: @escaping TransactionConsumption.RetrieveRequestCallback) -> TransactionConsumption.RetrieveRequest? {
        self.isApproveCalled = true
        self.approveCompletionClosure = callback
        return nil
    }

    func reject(consumption _: TransactionConsumption, callback: @escaping TransactionConsumption.RetrieveRequestCallback) -> TransactionConsumption.RetrieveRequest? {
        self.isRejectCalled = true
        self.rejectCompletionClosure = callback
        return nil
    }
}
