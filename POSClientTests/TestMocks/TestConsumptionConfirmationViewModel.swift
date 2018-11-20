//
//  TestConsumptionConfirmationViewModel.swift
//  POSClientTests
//
//  Created by Mederic Petit on 19/10/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import UIKit

class TestConsumptionConfirmationViewModel: ConsumptionConfirmationViewModelProtocol {
    var onSuccessApprove: SuccessClosure?
    var onFailApprove: FailureClosure?
    var onSuccessReject: SuccessClosure?
    var onFailReject: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    var title: String = "x"
    var direction: String = "x"
    var amountDisplay: String = "x"
    var confirmButtonTitle: String = "x"
    var rejectButtonTitle: String = "x"
    var accountName: String = "x"

    func approve() {
        self.didCallApprove = true
    }

    func reject() {
        self.didCallReject = true
    }

    var didCallApprove = false
    var didCallReject = false
}
