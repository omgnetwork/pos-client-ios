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
        self.sut = nil
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
}
