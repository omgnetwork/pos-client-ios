//
//  ProfileTableViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 11/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import Toaster
import XCTest

class ProfileTableViewControllerTests: XCTestCase {
    var sut: ProfileTableViewController!
    var viewModel: TestProfileTableViewModel!

    override func setUp() {
        super.setUp()
        self.viewModel = TestProfileTableViewModel()
        self.sut = ProfileTableViewController.initWithViewModel(self.viewModel)
        _ = UINavigationController(rootViewController: self.sut)
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        ToastCenter.default.cancelAll()
        self.sut = nil
        self.viewModel = nil
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.navigationItem.title, "x")
        XCTAssertEqual(self.sut.transactionLabel.text, "x")
        XCTAssertEqual(self.sut.emailLabel.text, "x")
        XCTAssertEqual(self.sut.emailValueLabel.text, "x")
        XCTAssertEqual(self.sut.touchFaceIdLabel.text, "x")
        XCTAssertEqual(self.sut.touchFaceIdSwitch.isOn, false)
        XCTAssertEqual(self.sut.signOutLabel.text, "x")
    }

    func testBioStateChangeUpdateSwitchState() {
        XCTAssertFalse(self.sut.touchFaceIdSwitch.isOn)
        self.viewModel.onBioStateChange?(true)
        XCTAssertTrue(self.sut.touchFaceIdSwitch.isOn)
    }

    func testShouldShowEnableConfirmationViewTriggersSegue() {
        let e = self.expectation(description: "shouldShowEnableConfirmationView pushes TouchIDConfirmationViewController")
        XCTAssertEqual(self.sut.navigationController!.viewControllers.count, 1)
        dispatchMain {
            self.viewModel.shouldShowEnableConfirmationView?()
            e.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(self.sut.navigationController!.viewControllers.count, 2)
        XCTAssertTrue(self.sut.navigationController!.viewControllers[1].isKind(of: TouchIDConfirmationViewController.self))
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

    func testFailedLogoutShowsError() {
        let error = POSClientError.unexpected
        self.viewModel.onFailLogout?(error)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, error.message)
    }

    func testUpdateSwitchStateWhenViewAppear() {
        self.viewModel.switchState = false
        XCTAssertFalse(self.sut.touchFaceIdSwitch.isOn)
        self.sut.touchFaceIdSwitch.isOn = true
        XCTAssertTrue(self.sut.touchFaceIdSwitch.isOn)
        self.sut.viewWillAppear(false)
        XCTAssertFalse(self.sut.touchFaceIdSwitch.isOn)
    }

    func testShowTransactionsVCWhenSelectingTransactions() {
        let e = self.expectation(description: "selecting transactions cell pushes TransactionsViewController")
        XCTAssertEqual(self.sut.navigationController!.viewControllers.count, 1)
        dispatchMain {
            self.sut.tableView(self.sut.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
            e.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(self.sut.navigationController!.viewControllers.count, 2)
        XCTAssertTrue(self.sut.navigationController!.viewControllers[1].isKind(of: TransactionsViewController.self))
    }

    func testLogoutIsTriggeredWhenSelectingLogout() {
        self.sut.tableView(self.sut.tableView, didSelectRowAt: IndexPath(row: 0, section: 2))
        XCTAssertTrue(self.viewModel.isLogoutCalled)
    }

    func testToggleSwitchIsCalledWhenChangingSwitchState() {
        self.sut.touchFaceIdSwitch.isOn = false
        self.sut.didUpdateSwitch(self.sut.touchFaceIdSwitch)
        XCTAssertFalse(self.viewModel.isToggleSwitchWithValue!)
        self.sut.touchFaceIdSwitch.isOn = true
        self.sut.didUpdateSwitch(self.sut.touchFaceIdSwitch)
        XCTAssertTrue(self.viewModel.isToggleSwitchWithValue!)
    }

    func testHeightAdjustsAccordingToBioAvailability() {
        self.viewModel.isBiometricAvailable = false
        let height1 = self.sut.tableView(self.sut.tableView, heightForRowAt: IndexPath(row: 1, section: 1))
        XCTAssertEqual(height1, 0)
        self.viewModel.isBiometricAvailable = true
        let height2 = self.sut.tableView(self.sut.tableView, heightForRowAt: IndexPath(row: 1, section: 1))
        XCTAssertEqual(height2, 44)
    }
}
