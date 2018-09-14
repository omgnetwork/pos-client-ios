//
//  LoginViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 6/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import Toaster
import XCTest

class LoginViewControllerTests: XCTestCase {
    var sut: LoginViewController!

    override func setUp() {
        super.setUp()
        self.sut = Storyboard.login.storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
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
        XCTAssertEqual(self.sut.emailTextField.placeholder, self.sut.viewModel.emailPlaceholder)
        XCTAssertEqual(self.sut.passwordTextField.placeholder, self.sut.viewModel.passwordPlaceholder)
        XCTAssertEqual(self.sut.loginButton.titleLabel?.text, self.sut.viewModel.loginButtonTitle)
        XCTAssertEqual(self.sut.registerButton.titleLabel?.text, self.sut.viewModel.registerButtonTitle)
        XCTAssertTrue(self.sut.bioLoginButton.isHidden)
    }

    func testInvalidEmailShowsError() {
        self.sut.viewModel.updateEmailValidation?("qwe")
        XCTAssertEqual(self.sut.emailTextField.errorMessage, "qwe")
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

    func testFailedLoginShowsError() {
        let error = POSClientError.unexpected
        self.sut.viewModel.onFailedLogin?(error)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, error.message)
    }

    func testEmailTextFieldChangeUpdatesViewModelEmailAttribute() {
        let range = NSRange(location: 0, length: 0)
        _ = self.sut.textField(self.sut.emailTextField, shouldChangeCharactersIn: range, replacementString: "123")
        XCTAssertEqual(self.sut.viewModel.email, "123")
    }

    func testPasswordTextFieldChangeUpdatesViewModelPasswordAttribute() {
        let range = NSRange(location: 0, length: 0)
        _ = self.sut.textField(self.sut.passwordTextField, shouldChangeCharactersIn: range, replacementString: "123")
        XCTAssertEqual(self.sut.viewModel.password, "123")
    }

    func testReturningEmailTFFocusPasswordTF() {
        self.mountOnWindow()
        self.sut.emailTextField.becomeFirstResponder()
        XCTAssertTrue(self.sut.emailTextField.isFirstResponder)
        _ = self.sut.textFieldShouldReturn(self.sut.emailTextField)
        let e = self.expectation(description: "Returning email tf focus password tf")
        dispatchMain { e.fulfill() }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(self.sut.passwordTextField.isFirstResponder)
    }

    func testReturningPasswordTFResignFirstResponderAndTriggersLogIn() {
        self.mountOnWindow()
        self.sut.passwordTextField.becomeFirstResponder()
        XCTAssertTrue(self.sut.passwordTextField.isFirstResponder)
        _ = self.sut.textFieldShouldReturn(self.sut.passwordTextField)
        let e = self.expectation(description: "Returning password tf triggers log in")
        dispatchMain { e.fulfill() }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(self.sut.passwordTextField.isFirstResponder)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, "Missing required fields")
    }

    func testClearEmailTFClearsViewModelEmail() {
        self.sut.viewModel.email = "123"
        _ = self.sut.textFieldShouldClear(self.sut.emailTextField)
        XCTAssertEqual(self.sut.viewModel.email, "")
    }

    func testClearPWTFClearsViewModelPW() {
        self.sut.viewModel.password = "123"
        _ = self.sut.textFieldShouldClear(self.sut.passwordTextField)
        XCTAssertEqual(self.sut.viewModel.password, "")
    }
}
