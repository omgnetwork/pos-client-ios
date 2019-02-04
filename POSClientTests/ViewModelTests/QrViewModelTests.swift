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
    var sessionManager: TestSessionManager!
    var transactionBuilder = TestTransactionRequestBuilder()
    var sut: QRViewModel!

    override func setUp() {
        super.setUp()
        self.sessionManager = TestSessionManager(wallet: StubGenerator.mainWallet())
        self.sut = QRViewModel(sessionManager: self.sessionManager, transactionRequestBuilder: self.transactionBuilder)
    }

    override func tearDown() {
        PrimaryTokenManager().clear()
        self.sessionManager = nil
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

    func testRaisesErrorWhenDecodingARequestWithoutAnAmount() {
        let verifier = QRClientVerifier(client: self.sessionManager.httpClient)
        let request = StubGenerator.transactionRequestWithoutAmount()
        let scanner = QRScannerViewController(delegate: self.sut, verifier: verifier, cancelButtonTitle: "cancel", viewModel: TestOmiseGOQRViewModel())
        var raisedError: POSClientError?
        var didCallRequestScanned = false
        self.sut.onFailure = {
            raisedError = $0
        }
        self.sut.onTransactionRequestScanned = { _ in
            didCallRequestScanned = true
        }
        self.sut.scannerDidDecode(scanner: scanner!, transactionRequest: request)
        XCTAssertNotNil(raisedError)
        XCTAssertEqual(raisedError!.message, "This request does not contain a valid amount")
        XCTAssertFalse(didCallRequestScanned)
    }

    func testCallsClosureWhenDecodingSuccessfully() {
        let verifier = QRClientVerifier(client: self.sessionManager.httpClient)
        let request = StubGenerator.transactionRequest()
        let scanner = QRScannerViewController(delegate: self.sut, verifier: verifier, cancelButtonTitle: "cancel", viewModel: TestOmiseGOQRViewModel())
        var decodedRequest: TransactionRequest?
        self.sut.onTransactionRequestScanned = {
            decodedRequest = $0
        }
        self.sut.scannerDidDecode(scanner: scanner!, transactionRequest: request)
        XCTAssertNotNil(decodedRequest)
        XCTAssertEqual(request, decodedRequest)
    }
}
