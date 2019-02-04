//
//  QRViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 10/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient
import SBToaster
import XCTest

class QRViewControllerTests: XCTestCase {
    var sut: QRViewController!
    var viewModel: TestQRViewModel!

    override func setUp() {
        super.setUp()
        self.viewModel = TestQRViewModel()
        self.sut = QRViewController.initWithViewModel(self.viewModel)
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        self.sut = nil
        self.viewModel = nil
    }

    private func mountOnWindow() {
        let w = UIWindow()
        w.addSubview(self.sut.view)
        w.makeKeyAndVisible()
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.hintLabel.text, "x")
        XCTAssertEqual(self.sut.navigationItem.title, "x")
        XCTAssertNil(self.sut.qrImageView.image)
        XCTAssertTrue(self.viewModel.didCallBuildTransactionRequests)
    }

    func testOnFailureShowsError() {
        let error = POSClientError.unexpected
        self.viewModel.onFailure?(error)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, error.message)
    }

    func testLoadStateChangeTriggersLoading() {
        let e = self.expectation(description: "loading state change triggers loading view to show/hide")
        self.viewModel.onLoadStateChange?(true)
        XCTAssertEqual(self.sut.loading!.alpha, 1.0)
        self.viewModel.onLoadStateChange?(false)
        dispatchMain(afterMilliseconds: 10) {
            e.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(self.sut.loading!.alpha, 0)
    }

    func testOnTransactionRequestGeneratedUpdateImage() {
        XCTAssertNil(self.sut.qrImageView.image)
        self.viewModel.onTransactionRequestGenerated?()
        XCTAssertEqual(self.viewModel.didCallQRImageWithWidth, self.sut.qrImageView.frame.width)
        XCTAssertNotNil(self.sut.qrImageView.image)
    }

    func testTapScanButtonPresentsScanner() {
        self.mountOnWindow()
        class DummyDelegate: QRScannerViewControllerDelegate { // swiftlint:disable:this nesting
            func scannerDidCancel(scanner _: QRScannerViewController) {}
            func scannerDidDecode(scanner _: QRScannerViewController, transactionRequest _: TransactionRequest) {}
            func scannerDidFailToDecode(scanner _: QRScannerViewController, withError _: OMGError) {}
        }

        self.sut.tapScanButton(UIBarButtonItem())

        let verifier = QRClientVerifier(client: TestSessionManager().httpClient)
        self.viewModel.qrScannerViewController = QRScannerViewController(delegate: DummyDelegate(), verifier: verifier, cancelButtonTitle: "cancel")
        XCTAssertTrue(self.viewModel.didCallPrepareScanner)
        XCTAssertEqual(self.sut.presentedViewController, self.viewModel.qrScannerViewController)
    }

    func testOntransactionRequestScannedCallsSegue() {
        let navVC = UINavigationController(rootViewController: self.sut)
        _ = self.sut.view
        XCTAssertEqual(navVC.viewControllers.count, 1)
        let request = StubGenerator.transactionRequest()
        self.viewModel.onTransactionRequestScanned?(request)
        let e = self.expectation(description: "pushes confirmation view controller")
        dispatchMain {
            e.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(navVC.viewControllers.count, 2)
        let detailVC = navVC.viewControllers.last!
        XCTAssertTrue(detailVC.isKind(of: TransactionConfirmationViewController.self))
    }
}
