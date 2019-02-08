//
//  QrViewModelTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 18/10/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import OmiseGO
@testable import POSClient
import XCTest

class QrViewModelTests: XCTestCase {
    var transactionBuilder = TestTransactionRequestBuilder()
    var sut: QRViewModel!

    override func setUp() {
        super.setUp()
        self.sut = QRViewModel(transactionRequestBuilder: self.transactionBuilder)
    }

    override func tearDown() {
        PrimaryTokenManager().clear()
        self.sut = nil
        super.tearDown()
    }

    func testBuildTransactionRequestFailsIfThereIsNoPrimaryToken() {
        PrimaryTokenManager().clear()
        let e = self.expectation(description: "build transaction request fails without primary token")
        var error: POSClientError?
        self.sut.onFailure = {
            error = $0
            e.fulfill()
        }
        self.sut.buildTransactionRequests()
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertNotNil(error)
    }

    func testBuildTransactionRequestSucceedWithAPrimaryToken() {
        let e = self.expectation(description: "build transaction request succeed with primary token")
        PrimaryTokenManager().setPrimary(tokenId: "123")
        var count = 0
        self.sut.onTransactionRequestGenerated = {
            count += 1
            if count == 2 {
                e.fulfill()
            }
        }
        self.sut.buildTransactionRequests()
        self.transactionBuilder.buildSuccess(withData: "1".data(using: .utf8)!)
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(count, 2)
    }

    func testBuildTransactionRequestFailsWithAPrimaryTokenAndAnError() {
        let e = self.expectation(description: "build transaction request fails with primary token but with an encountred error")
        PrimaryTokenManager().setPrimary(tokenId: "123")
        let givenError = POSClientError.message(message: "test")
        var error: POSClientError?
        self.sut.onFailure = {
            error = $0
            e.fulfill()
        }
        self.sut.buildTransactionRequests()
        self.transactionBuilder.buildFailure(withError: givenError)
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(givenError.message, error?.message)
    }
}
