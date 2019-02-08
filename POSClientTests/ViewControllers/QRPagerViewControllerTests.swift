//
//  QRPagerViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 7/2/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

@testable import OmiseGO
@testable import POSClient
import SBToaster
import XCTest
import XLPagerTabStrip

class QRPagerViewControllerTests: XCTestCase {
    var sut: QRPagerViewController!
    var viewModel: TestQRPagerViewModel!

    override func setUp() {
        super.setUp()
        self.viewModel = TestQRPagerViewModel()
        let qrViewModel = TestQRViewModel()
        self.sut = QRPagerViewController.initWithViewModel(self.viewModel, qrViewModel: qrViewModel)
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
        XCTAssertEqual(self.sut.navigationItem.title, "x")
    }

    func testOnFailureShowsError() {
        let error = POSClientError.unexpected
        self.viewModel.onFailure?(error)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, error.message)
    }

    func testStartObservingOnViewDidAppear() {
        XCTAssertFalse(self.viewModel.didCallStartObserving)
        self.sut.viewDidAppear(true)
        XCTAssertTrue(self.viewModel.didCallStartObserving)
    }

    func testStopObservingOnViewDidAppear() {
        XCTAssertFalse(self.viewModel.didCallStopObserving)
        self.sut.viewWillDisappear(true)
        XCTAssertTrue(self.viewModel.didCallStopObserving)
    }

    func testToggleTabOnBarButtonNotification() {
        self.mountOnWindow()

        XCTAssertEqual(self.sut.currentIndex, 0)

        let e1 = self.expectation(description: "Updates current index to 1")
        dispatchMain(afterMilliseconds: 300) {
            e1.fulfill()
        }
        self.viewModel.onBarButtonNotificationToggle?()
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(self.sut.currentIndex, 1)

        let e0 = self.expectation(description: "Updates current index to 0")
        dispatchMain(afterMilliseconds: 300) {
            e0.fulfill()
        }
        self.viewModel.onBarButtonNotificationToggle?()
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(self.sut.currentIndex, 0)
    }

    func testProvidesCorrectControllersToBarMenuWhenScanAvailable() {
        class DummyDelegate: QRScannerViewControllerDelegate { // swiftlint:disable:this nesting
            func scannerDidCancel(scanner _: QRScannerViewController) {}
            func scannerDidDecode(scanner _: QRScannerViewController, transactionRequest _: TransactionRequest) {}
            func scannerDidFailToDecode(scanner _: QRScannerViewController, withError _: OMGError) {}
        }

        let verifier = QRClientVerifier(client: TestSessionManager().httpClient)
        self.viewModel.qrScannerViewController = QRScannerViewController(delegate: DummyDelegate(),
                                                                         verifier: verifier,
                                                                         cancelButtonTitle: "",
                                                                         viewModel: TestOmiseGOQRViewModel())
        self.sut.reloadPagerTabStripView()
        let viewControllers = self.sut.viewControllers
        XCTAssertEqual(viewControllers.count, 2)
        XCTAssertTrue(viewControllers.first!.isKind(of: QRViewController.self))
        XCTAssertTrue(viewControllers[1].isKind(of: QRScannerViewController.self))
    }

    func testProvidesCorrectControllersToBarMenyWhenScanNotAvailable() {
        self.sut.reloadPagerTabStripView()
        let viewControllers = self.sut.viewControllers
        XCTAssertEqual(viewControllers.count, 2)
        XCTAssertTrue(viewControllers.first!.isKind(of: QRViewController.self))
        XCTAssertTrue(viewControllers[1].isKind(of: ScannerNotAvailableViewController.self))
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
