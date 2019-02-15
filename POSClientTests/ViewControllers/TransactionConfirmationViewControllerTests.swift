//
//  TransactionConfirmationViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 4/2/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient
import SBToaster
import XCTest

class TransactionConfirmationViewControllerTests: XCTestCase {
    var sut: TransactionConfirmationViewController!
    var viewModel: TestTransactionConfirmationViewModel!

    override func setUp() {
        super.setUp()
        self.viewModel = TestTransactionConfirmationViewModel()
        self.sut = TransactionConfirmationViewController.initWithViewModel(self.viewModel)
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        ToastCenter.default.cancelAll()
        self.sut = nil
        self.viewModel = nil
    }

    func mountOnWindow() {
        let w = UIWindow()
        w.addSubview(self.sut.view)
        w.makeKeyAndVisible()
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.title, "x")
        XCTAssertEqual(self.sut.tokenLabel.text, "x")
        XCTAssertEqual(self.sut.directionLabel.text, "x")
        XCTAssertEqual(self.sut.accountNameLabel.text, "x")
        XCTAssertEqual(self.sut.accountIdLabel.text, "x")
        XCTAssertEqual(self.sut.confirmButton.titleLabel?.text, "x")
        XCTAssertEqual(self.sut.cancelButton.titleLabel?.text, "x")
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

    func testOnPendingConsumptionShowsConfirmationView() {
        self.mountOnWindow()
        XCTAssertNil(self.sut.presentedViewController)
        self.viewModel.onPendingConsumptionConfirmation?()
        XCTAssertNotNil(self.sut.presentedViewController)
    }

    func testOnCompleteConsumption() {
        let request = StubGenerator.transactionRequest()
        let builder = TransactionBuilder(transactionRequest: request)
        let navVC = UINavigationController(rootViewController: self.sut)
        let w = UIWindow()
        w.addSubview(navVC.view)
        w.makeKeyAndVisible()
        let e = self.expectation(description: "Push view controller")
        self.viewModel.onCompletedConsumption?(builder)
        dispatchMain {
            e.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(navVC.viewControllers.count, 2)
    }

    func testTapConfirmButtonCallsConsume() {
        self.sut.tapConfirmButton(self.sut.confirmButton)
        XCTAssertTrue(self.viewModel.consumeCalled)
    }

    func testTapCancelButtonPopsController() {
        let dummyVC = UIViewController()
        let navVC = UINavigationController()
        let w = UIWindow()
        w.addSubview(navVC.view)
        w.makeKeyAndVisible()
        navVC.viewControllers = [dummyVC, self.sut]
        let e = self.expectation(description: "Pops view controller")
        self.sut.tapCancelButton(UIButton())
        dispatchMain {
            e.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(navVC.viewControllers.count, 1)
        XCTAssertTrue(self.viewModel.stopListeningCalled)
    }
}
