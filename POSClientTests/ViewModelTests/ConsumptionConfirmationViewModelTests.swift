//
//  ConsumptionConfirmationViewModelTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 19/10/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient
import XCTest

class ConsumptionConfirmationViewModelTests: XCTestCase {
    var transactionConsumptionApprover: TestTransactionConsumptionApprover!
    var sut: ConsumptionConfirmationViewModel!
    let testConsumption = StubGenerator.transactionConsumption()

    override func setUp() {
        super.setUp()
        self.transactionConsumptionApprover = TestTransactionConsumptionApprover()
        self.sut = ConsumptionConfirmationViewModel(transactionConsumptionApprover: self.transactionConsumptionApprover,
                                                    consumption: self.testConsumption)
    }

    override func tearDown() {
        self.transactionConsumptionApprover = nil
        self.sut = nil
        super.tearDown()
    }

    func testInitsValueCorrectly() {
        XCTAssertEqual(self.sut.title, "consumption_confirmation.send".localized())
        XCTAssertEqual(self.sut.direction, "consumption_confirmation.to".localized())
        XCTAssertEqual(self.sut.accountName, "Headquarter")
        XCTAssertEqual(self.sut.amountDisplay, "1 TK1")
    }

    func testSuccessApproveCallsOnSuccess() {
        var didCallOnSuccess = false
        self.sut.onSuccessApprove = {
            didCallOnSuccess = true
        }
        self.sut.approve()
        self.transactionConsumptionApprover.approveSuccess(withConsumption: self.testConsumption)
        XCTAssertTrue(self.transactionConsumptionApprover.isApproveCalled)
        XCTAssertTrue(didCallOnSuccess)
    }

    func testFailApproveCallsOnFail() {
        var error: POSClientError?
        let expectedError = OMGError.unexpected(message: "test")
        self.sut.onFailApprove = {
            error = $0
        }
        self.sut.approve()
        self.transactionConsumptionApprover.approveFailed(withError: expectedError)
        XCTAssertTrue(self.transactionConsumptionApprover.isApproveCalled)
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.message, "unexpected error: test")
    }

    func testSuccessRejectCallsOnSuccess() {
        var didCallOnSuccess = false
        self.sut.onSuccessReject = {
            didCallOnSuccess = true
        }
        self.sut.reject()
        self.transactionConsumptionApprover.rejectSuccess(withConsumption: self.testConsumption)
        XCTAssertTrue(self.transactionConsumptionApprover.isRejectCalled)
        XCTAssertTrue(didCallOnSuccess)
    }

    func testFailRejectCallsOnFail() {
        var error: POSClientError?
        let expectedError = OMGError.unexpected(message: "test")
        self.sut.onFailReject = {
            error = $0
        }
        self.sut.reject()
        self.transactionConsumptionApprover.rejectFailed(withError: expectedError)
        XCTAssertTrue(self.transactionConsumptionApprover.isRejectCalled)
        XCTAssertNotNil(error)
        XCTAssertEqual(error?.message, "unexpected error: test")
    }

    func testShowLoadingWhenApproving() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        XCTAssertFalse(loadingStatus)
        self.sut.approve()
        XCTAssertTrue(loadingStatus)
        self.transactionConsumptionApprover.approveSuccess(withConsumption: self.testConsumption)
        XCTAssertFalse(loadingStatus)
    }

    func testShowLoadingWhenRejecting() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        XCTAssertFalse(loadingStatus)
        self.sut.reject()
        XCTAssertTrue(loadingStatus)
        self.transactionConsumptionApprover.rejectSuccess(withConsumption: self.testConsumption)
        XCTAssertFalse(loadingStatus)
    }
}
