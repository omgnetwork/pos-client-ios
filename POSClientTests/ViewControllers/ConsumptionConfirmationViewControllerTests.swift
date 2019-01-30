//
//  ConsumptionConfirmationViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 19/10/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import SBToaster
import XCTest

class ConsumptionConfirmationViewControllerTests: XCTestCase {
    var sut: ConsumptionConfirmationViewController!
    var viewModel: TestConsumptionConfirmationViewModel!

    override func setUp() {
        super.setUp()
        self.viewModel = TestConsumptionConfirmationViewModel()
        self.sut = ConsumptionConfirmationViewController.initWithViewModel(self.viewModel)
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        ToastCenter.default.cancelAll()
        self.sut = nil
        self.viewModel = nil
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.titleLabel.text, "x")
        XCTAssertEqual(self.sut.tokenLabel.text, "x")
        XCTAssertEqual(self.sut.directionLabel.text, "x")
        XCTAssertEqual(self.sut.accountNameLabel.text, "x")
        XCTAssertEqual(self.sut.confirmButton.titleLabel?.text, "x")
        XCTAssertEqual(self.sut.rejectButton.titleLabel?.text, "x")
    }

    func testFailedApproveShowsError() {
        let error = POSClientError.unexpected
        self.viewModel.onFailApprove?(error)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, error.message)
    }

    func testFailedRejectShowsError() {
        let error = POSClientError.unexpected
        self.viewModel.onFailReject?(error)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, error.message)
    }

    func testSuccessApproveDismissTheController() {
        let e = self.expectation(description: "dismisses the controller on successful approval")
        let dummyPresenter = UIViewController(nibName: nil, bundle: nil)
        let w = UIWindow()
        w.addSubview(dummyPresenter.view)
        w.makeKeyAndVisible()
        dummyPresenter.present(self.sut, animated: false) {
            XCTAssertNotNil(dummyPresenter.presentedViewController)
            self.viewModel.onSuccessApprove?()
            e.fulfill()
        }
        self.waitForExpectations(timeout: 2, handler: nil)
        XCTAssertTrue(self.sut.isBeingDismissed)
    }

    func testSuccessRejectDismissTheController() {
        let e = self.expectation(description: "dismisses the controller on successful rejection")
        let dummyPresenter = UIViewController(nibName: nil, bundle: nil)
        let w = UIWindow()
        w.addSubview(dummyPresenter.view)
        w.makeKeyAndVisible()
        dummyPresenter.present(self.sut, animated: false) {
            XCTAssertNotNil(dummyPresenter.presentedViewController)
            self.viewModel.onSuccessReject?()
            e.fulfill()
        }
        self.waitForExpectations(timeout: 2, handler: nil)
        XCTAssertTrue(self.sut.isBeingDismissed)
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

    func testTapConfirmButtonCallsApprove() {
        self.sut.tapConfirmButton(self.sut.confirmButton)
        XCTAssertTrue(self.viewModel.didCallApprove)
    }

    func testTapRejectButtonCallsReject() {
        self.sut.tapRejectButton(self.sut.rejectButton)
        XCTAssertTrue(self.viewModel.didCallReject)
    }

    func testTapCloseButtonDismissTheController() {
        let e = self.expectation(description: "dismisses the controller on tap on close")
        let dummyPresenter = UIViewController(nibName: nil, bundle: nil)
        let w = UIWindow()
        w.addSubview(dummyPresenter.view)
        w.makeKeyAndVisible()
        dummyPresenter.present(self.sut, animated: false) {
            XCTAssertNotNil(dummyPresenter.presentedViewController)
            self.sut.tapCloseButton(UIButton(type: .system))
            e.fulfill()
        }
        self.waitForExpectations(timeout: 2, handler: nil)
        XCTAssertTrue(self.sut.isBeingDismissed)
    }
}
