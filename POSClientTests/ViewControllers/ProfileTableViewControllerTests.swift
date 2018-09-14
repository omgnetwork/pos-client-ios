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

    override func setUp() {
        super.setUp()
        self.sut =
            Storyboard.profile.storyboard.instantiateViewController(withIdentifier: "ProfileTableViewController") as! ProfileTableViewController
        _ = UINavigationController(rootViewController: self.sut)
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        ToastCenter.default.cancelAll()
        self.sut = nil
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.navigationItem.title, self.sut.viewModel.title)
        XCTAssertEqual(self.sut.transactionLabel.text, self.sut.viewModel.transactionLabelText)
        XCTAssertEqual(self.sut.emailLabel.text, self.sut.viewModel.emailLabelText)
        XCTAssertEqual(self.sut.emailValueLabel.text, self.sut.viewModel.emailValueLabelText)
        XCTAssertEqual(self.sut.touchFaceIdLabel.text, self.sut.viewModel.touchFaceIdLabelText)
        XCTAssertEqual(self.sut.touchFaceIdSwitch.isOn, self.sut.viewModel.switchState)
        XCTAssertEqual(self.sut.signOutLabel.text, self.sut.viewModel.signOutLabelText)
    }

    func testBioStateChangeUpdateSwitchState() {
        XCTAssertFalse(self.sut.touchFaceIdSwitch.isOn)
        self.sut.viewModel.onBioStateChange?(true)
        XCTAssertTrue(self.sut.touchFaceIdSwitch.isOn)
    }

    func testShouldShowEnableConfirmationViewTriggersSegue() {
        let e = self.expectation(description: "shouldShowEnableConfirmationView pushes TouchIDConfirmationViewController")
        XCTAssertEqual(self.sut.navigationController!.viewControllers.count, 1)
        dispatchMain {
            self.sut.viewModel.shouldShowEnableConfirmationView?()
            e.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(self.sut.navigationController!.viewControllers.count, 2)
        XCTAssertTrue(self.sut.navigationController!.viewControllers[1].isKind(of: TouchIDConfirmationViewController.self))
    }

    func testLoadStateChangeTriggersLoading() {
        let e = self.expectation(description: "loading state change triggers loading view to show/hide")
        self.sut.viewModel.onLoadStateChange?(true)
        XCTAssertEqual(self.sut.loading!.alpha, 1.0)
        self.sut.viewModel.onLoadStateChange?(false)
        dispatchMain(afterMilliseconds: 10) {
            e.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(self.sut.loading!.alpha, 0)
    }

    func testFailedLogoutShowsError() {
        let error = POSClientError.unexpected
        self.sut.viewModel.onFailLogout?(error)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, error.message)
    }

    func testUpdateSwitchStateWhenViewAppear() {
        self.sut.viewModel.switchState = false
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
        // TODO: after refactor
    }

    func testHeightAdjustsAccordingToBioAvailability() {
        self.sut.viewModel.isBiometricAvailable = false
        let height1 = self.sut.tableView(self.sut.tableView, heightForRowAt: IndexPath(row: 1, section: 1))
        XCTAssertEqual(height1, 0)
        self.sut.viewModel.isBiometricAvailable = true
        let height2 = self.sut.tableView(self.sut.tableView, heightForRowAt: IndexPath(row: 1, section: 1))
        XCTAssertEqual(height2, 44)
    }
}
