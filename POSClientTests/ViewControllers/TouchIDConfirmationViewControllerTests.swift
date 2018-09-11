//
//  TouchIDConfirmationViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 11/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import Toaster
import XCTest

class TouchIDConfirmationViewControllerTests: XCTestCase {
    var sut: TouchIDConfirmationViewController!

    override func setUp() {
        super.setUp()
        self.sut =
            Storyboard.profile.storyboard.instantiateViewController(withIdentifier: "TouchIDConfirmationViewController") as! TouchIDConfirmationViewController
        _ = UINavigationController(rootViewController: self.sut)
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        ToastCenter.default.cancelAll()
        self.sut = nil
    }

    private func mountOnWindow() {
        let w = UIWindow()
        w.addSubview(self.sut.view)
        w.makeKeyAndVisible()
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.emailLabel.text, self.sut.viewModel.emailString)
        XCTAssertEqual(self.sut.passwordTextField.placeholder, self.sut.viewModel.passwordPlaceholder)
        XCTAssertEqual(self.sut.hintLabel.text, self.sut.viewModel.hintString)
        XCTAssertEqual(self.sut.enableButton.titleLabel?.text, self.sut.viewModel.enableButtonTitle)
    }

    func testInvalidPasswordShowsError() {
        self.sut.viewModel.updatePasswordValidation?("123")
        XCTAssertEqual(self.sut.passwordTextField.errorMessage, "123")
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

    func testFailedEnableShowsError() {
        let error = POSClientError.unexpected
        self.sut.viewModel.onFailedEnable?(error)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, error.message)
    }

    func testOnSuccessEnablePopsViewController() {
        let dummyVC = UIViewController(nibName: nil, bundle: nil)
        let navVC = UINavigationController(rootViewController: dummyVC)
        navVC.pushViewController(self.sut, animated: false)
        XCTAssertEqual(navVC.viewControllers.count, 2)
        let e = self.expectation(description: "Pops view controller")
        self.sut.viewModel.onSuccessEnable?()
        dispatchMain {
            e.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(navVC.viewControllers.count, 1)
        XCTAssertEqual(navVC.viewControllers[0], dummyVC)
    }

    func testPasswordTextFieldChangeUpdatesViewModelPasswordAttribute() {
        let range = NSRange(location: 0, length: 0)
        _ = self.sut.textField(self.sut.passwordTextField, shouldChangeCharactersIn: range, replacementString: "123")
        XCTAssertEqual(self.sut.viewModel.password, "123")
    }

    func testReturningPasswordTFResignFirstResponderAndTriggersEnable() {
        self.mountOnWindow()
        self.sut.passwordTextField.becomeFirstResponder()
        XCTAssertTrue(self.sut.passwordTextField.isFirstResponder)
        _ = self.sut.textFieldShouldReturn(self.sut.passwordTextField)
        let e = self.expectation(description: "Returning password tf triggers enable")
        dispatchMain { e.fulfill() }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(self.sut.passwordTextField.isFirstResponder)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, "Missing required fields")
    }

    func testClearPWTFClearsViewModelPW() {
        self.sut.viewModel.password = "123"
        _ = self.sut.textFieldShouldClear(self.sut.passwordTextField)
        XCTAssertEqual(self.sut.viewModel.password, "")
    }
}
