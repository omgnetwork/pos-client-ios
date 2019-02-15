//
//  TestTransactionConfirmationViewModel.swift
//  POSClientTests
//
//  Created by Mederic Petit on 4/2/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import UIKit

class TestTransactionConfirmationViewModel: TransactionConfirmationViewModelProtocol {
    var onSuccessGetTransactionRequest: SuccessClosure?
    var onFailGetTransactionRequest: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?
    var onCompletedConsumption: ObjectClosure<TransactionBuilder>?
    var onPendingConsumptionConfirmation: EmptyClosure?

    var title: String = "x"
    var direction: String = "x"
    var amountDisplay: String = "x"
    var confirm: String = "x"
    var cancel: String = "x"
    var accountName: String = "x"
    var accountId: String = "x"
    var userExpectedAmountDisplay: String = "x"

    var consumeCalled = false
    var stopListeningCalled = false
    var waitingForUserConfirmationDidCancelCalled = false

    func consume() {
        self.consumeCalled = true
    }

    func stopListening() {
        self.stopListeningCalled = true
    }

    func waitingForUserConfirmationDidCancel() {
        self.waitingForUserConfirmationDidCancelCalled = true
    }
}
