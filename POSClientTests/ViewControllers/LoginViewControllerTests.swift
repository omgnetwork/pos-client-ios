//
//  LoginViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 6/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import SBToaster
import XCTest

class LoginViewControllerTests: XCTestCase {
    var sut: LoginViewController!
    var viewModel: TestLoginViewModel!

    override func setUp() {
        super.setUp()
        self.viewModel = TestLoginViewModel()
        self.sut = LoginViewController.initWithViewModel(self.viewModel)
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        ToastCenter.default.cancelAll()
        self.viewModel = nil
        self.sut = nil
    }

    private func mountOnWindow() {
        let w = UIWindow()
        w.addSubview(self.sut.view)
        w.makeKeyAndVisible()
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.emailTextField.placeholder, "x")
        XCTAssertEqual(self.sut.passwordTextField.placeholder, "x")
        XCTAssertEqual(self.sut.loginButton.titleLabel?.text, "x")
        XCTAssertEqual(self.sut.registerButton.titleLabel?.text, "x")
        XCTAssertTrue(self.sut.bioLoginButton.isHidden)
    }

    func testBioLoginButtonSetupsCorrectly() {
        let viewModel = TestLoginViewModel()
        viewModel.isBiometricAvailable = true
        let sut = LoginViewController.initWithViewModel(viewModel)!
        _ = sut.view
        XCTAssertFalse(sut.bioLoginButton.isHidden)
        XCTAssertEqual(sut.bioLoginButton.titleLabel?.text, "x")
    }

    func testInvalidEmailShowsError() {
        self.viewModel.updateEmailValidation?("qwe")
        XCTAssertEqual(self.sut.emailTextField.errorMessage, "qwe")
    }

    func testInvalidPasswordShowsError() {
        self.viewModel.updatePasswordValidation?("123")
        XCTAssertEqual(self.sut.passwordTextField.errorMessage, "123")
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

    func testFailedLoginShowsError() {
        let error = POSClientError.unexpected
        self.viewModel.onFailedLogin?(error)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, error.message)
    }

    func testEmailTextFieldChangeUpdatesViewModelEmailAttribute() {
        let range = NSRange(location: 0, length: 0)
        _ = self.sut.textField(self.sut.emailTextField, shouldChangeCharactersIn: range, replacementString: "123")
        XCTAssertEqual(self.viewModel.email, "123")
    }

    func testPasswordTextFieldChangeUpdatesViewModelPasswordAttribute() {
        let range = NSRange(location: 0, length: 0)
        _ = self.sut.textField(self.sut.passwordTextField, shouldChangeCharactersIn: range, replacementString: "123")
        XCTAssertEqual(self.viewModel.password, "123")
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
        XCTAssertTrue(self.viewModel.isLoginCalled)
    }

    func testClearEmailTFClearsViewModelEmail() {
        self.viewModel.email = "123"
        _ = self.sut.textFieldShouldClear(self.sut.emailTextField)
        XCTAssertEqual(self.viewModel.email, "")
    }

    func testClearPWTFClearsViewModelPW() {
        self.viewModel.password = "123"
        _ = self.sut.textFieldShouldClear(self.sut.passwordTextField)
        XCTAssertEqual(self.viewModel.password, "")
    }

    func testTapLoginButtonTriggersLoginAndResignFirstResponder() {
        self.mountOnWindow()
        self.sut.emailTextField.becomeFirstResponder()
        XCTAssertTrue(self.sut.emailTextField.isFirstResponder)
        self.sut.tapLoginButton(self.sut.loginButton)
        let e = self.expectation(description: "Tap on log in button resigns first responder and trigger log in")
        dispatchMain { e.fulfill() }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(self.sut.emailTextField.isFirstResponder)
        XCTAssertTrue(self.viewModel.isLoginCalled)
    }

    func testTapBioLoginButtonTriggersBioLoginAndResignFirstResponder() {
        self.mountOnWindow()
        self.sut.emailTextField.becomeFirstResponder()
        XCTAssertTrue(self.sut.emailTextField.isFirstResponder)
        self.sut.tapBioLoginButton(self.sut.bioLoginButton)
        let e = self.expectation(description: "Tap on bio log in button resigns first responder and trigger bio log in")
        dispatchMain { e.fulfill() }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(self.sut.emailTextField.isFirstResponder)
        XCTAssertTrue(self.viewModel.isBioLoginCalled)
    }
}
