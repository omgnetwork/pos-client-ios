//
//  TransactionConfirmationViewModelTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 4/2/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient
import XCTest

class TransactionConfirmationViewModelTests: XCTestCase {
    var sut: TransactionConfirmationViewModel!
    var sessionManager: TestSessionManager!
    var transactionBuilder: TransactionBuilder!
    var transactionConsumptionGenerator: TestTransactionConsumptionGenerator!
    var transactionConsumptionRejector: TestTransactionConsumptionRejector!

    override func setUp() {
        super.setUp()
        self.sessionManager = TestSessionManager()
        self.transactionConsumptionGenerator = TestTransactionConsumptionGenerator()
        self.transactionConsumptionRejector = TestTransactionConsumptionRejector()
        let request = StubGenerator.transactionRequest()
        self.sut = TransactionConfirmationViewModel(sessionManager: self.sessionManager,
                                                    transactionConsumptionGenerator: self.transactionConsumptionGenerator,
                                                    transactionRequest: request,
                                                    transactionConsumptionRejector: self.transactionConsumptionRejector)
    }

    override func tearDown() {
        self.sut = nil
        self.sessionManager = nil
        self.transactionBuilder = nil
        self.transactionConsumptionGenerator = nil
        super.tearDown()
    }

    func testSetup() {
        XCTAssertEqual(self.sut.amountDisplay, "1 TK1")
        XCTAssertEqual(self.sut.title, "transaction_request_confirmation.send".localized())
        XCTAssertEqual(self.sut.direction, "transaction_request_confirmation.to".localized())
    }

    func testConsumeCalled() {
        self.sut.consume()
        XCTAssertNotNil(self.transactionConsumptionGenerator.consumedCalledWithParams)
    }

    func testConsumeFailure() {
        var builder: TransactionBuilder?
        let error = OMGError.unexpected(message: "fail")
        self.sut.onCompletedConsumption = {
            builder = $0
        }
        self.sut.consume()
        self.transactionConsumptionGenerator.failure(withError: error)
        XCTAssertEqual(builder?.error?.message, "unexpected error: fail")
    }

    func testConsumeSuccessWithConfirmation() {
        let consumption = StubGenerator.transactionConsumptionAccountGeneratedWithConfirmation()
        var success = false
        self.sut.onPendingConsumptionConfirmation = {
            success = true
        }
        self.sut.consume()
        self.transactionConsumptionGenerator.success(withConsumption: consumption)
        XCTAssertTrue(success)
    }

    func testConsumeSuccessWithoutConfirmation() {
        let consumption = StubGenerator.transactionConsumptionAccountGenerated()
        var builder: TransactionBuilder?
        self.sut.onCompletedConsumption = {
            builder = $0
        }
        self.sut.consume()
        self.transactionConsumptionGenerator.success(withConsumption: consumption)
        XCTAssertEqual(builder?.transactionConsumption, consumption)
    }

    func testShowLoadingWhenConsuming() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        XCTAssertFalse(loadingStatus)
        self.sut.consume()
        XCTAssertTrue(loadingStatus)
        self.transactionConsumptionGenerator.success(withConsumption: StubGenerator.transactionConsumptionAccountGenerated())
        XCTAssertFalse(loadingStatus)
    }

    func testCancelPendingConfirmation() {
        let consumption = StubGenerator.transactionConsumptionAccountGeneratedWithConfirmation()
        self.sut.consume()
        self.transactionConsumptionGenerator.success(withConsumption: consumption)
        self.sut.waitingForUserConfirmationDidCancel()
        XCTAssertEqual(self.transactionConsumptionRejector.consumption, consumption)
    }

    func testOnSuccessfulConsumptionFinalized() {
        let consumption = StubGenerator.transactionConsumptionAccountGenerated()
        var builder: TransactionBuilder?
        self.sut.onCompletedConsumption = {
            builder = $0
        }
        self.sut.onSuccessfulTransactionConsumptionFinalized(consumption)
        XCTAssertEqual(builder?.transactionConsumption, consumption)
    }
}
