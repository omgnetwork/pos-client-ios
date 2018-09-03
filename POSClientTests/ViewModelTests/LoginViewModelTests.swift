//
//  LoginViewModelTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 3/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient
import XCTest

class LoginViewModelTests: XCTestCase {
    var sessionManager: TestSessionManager!
    var sut: LoginViewModel!

    override func setUp() {
        super.setUp()
        self.sessionManager = TestSessionManager(isBiometricAvailable: true)
        self.sut = LoginViewModel(sessionManager: self.sessionManager)
    }

    override func tearDown() {
        self.sessionManager = nil
        self.sut = nil
        super.tearDown()
    }

    func testInvalidEmailAndPassword() {
        var emailError: String?
        var passwordError: String?
        self.sut.updateEmailValidation = { emailError = $0 }
        self.sut.updatePasswordValidation = { passwordError = $0 }
        self.sut.email = "anInvalidEmail"
        self.sut.password = "2shor"
        XCTAssert(emailError == "login.error.validation.email".localized())
        XCTAssert(passwordError == "login.error.validation.password".localized())
    }

    func testValidEmailAndPasswords() {
        var emailError: String?
        var passwordError: String?
        self.sut.updateEmailValidation = { emailError = $0 }
        self.sut.updatePasswordValidation = { passwordError = $0 }
        self.fillValidCredentials()
        XCTAssert(emailError == nil)
        XCTAssert(passwordError == nil)
    }

    func testLoginCalled() {
        self.fillValidCredentials()
        self.sut.login()
        XCTAssert(self.sessionManager.loginCalled)
    }

    func testLoginFailed() {
        var didFail = false
        self.fillValidCredentials()
        let error: OMGError = .unexpected(message: "Failed to load user")
        self.sut.onFailedLogin = {
            XCTAssertEqual($0.message, error.message)
            didFail = true
        }
        self.sut.login()
        self.sessionManager.loginFailed(withError: error)
        XCTAssert(didFail)
    }

    func testShowLoadingWhenLogin() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        XCTAssertFalse(loadingStatus)
        self.fillValidCredentials()
        self.sut.login()
        XCTAssertTrue(loadingStatus)
        self.sessionManager.loginSuccess()
        XCTAssertFalse(loadingStatus)
    }

    func testBioLoginCalled() {
        self.sut.bioLogin()
        XCTAssert(self.sessionManager.bioLoginCalled)
    }

    private func fillValidCredentials() {
        self.sut.email = "email@example.com"
        self.sut.password = "aV@1IdP@ssWord"
    }
}

extension LoginViewModelTests {
    private func goToLoginFinished() {
        self.fillValidCredentials()
        self.sut.login()
        self.sessionManager.loginSuccess()
    }
}
