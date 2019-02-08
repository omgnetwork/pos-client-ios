//
//  QRPagerViewModelTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 7/2/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

@testable import OmiseGO
@testable import POSClient
import XCTest

class QRPagerViewModelTests: XCTestCase {
    var sessionManager: TestSessionManager!
    var transactionBuilder = TestTransactionRequestBuilder()
    var sut: QRPagerViewModel!

    override func setUp() {
        super.setUp()
        self.sessionManager = TestSessionManager(wallet: StubGenerator.mainWallet())
        self.sut = QRPagerViewModel(sessionManager: self.sessionManager)
    }

    override func tearDown() {
        PrimaryTokenManager().clear()
        self.sessionManager = nil
        self.sut = nil
        super.tearDown()
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

    func testBarButtonNotificationCallsClosure() {
        var didToggle = false
        self.sut.onBarButtonNotificationToggle = {
            didToggle = true
        }
        self.sut.observerTabBarSelectNotification()
        NotificationCenter.default.post(name: .onTapQRTabBarButton, object: nil)
        XCTAssertTrue(didToggle)
    }
}
