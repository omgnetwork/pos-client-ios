//
//  SignupViewModelTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 4/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient
import XCTest

class SignupViewModelTests: XCTestCase {
    var sessionManager: TestSessionManager!
    var sut: SignupViewModel!

    override func setUp() {
        super.setUp()
        self.sessionManager = TestSessionManager()
        self.sut = SignupViewModel(sessionManager: self.sessionManager)
    }

    override func tearDown() {
        self.sessionManager = nil
        self.sut = nil
        super.tearDown()
    }

    func testInvalidEmail() {
        var emailError: String?
        self.sut.updateEmailValidation = { emailError = $0 }
        self.sut.email = "anInvalidEmail"
        XCTAssertEqual(emailError, "signup.error.validation.email".localized())
    }

    func testInvalidPassword() {
        var passwordError: String?
        self.sut.updatePasswordValidation = { passwordError = $0 }
        self.sut.password = "2shor"
        XCTAssertEqual(passwordError, "signup.error.validation.password".localized())
    }

    func testInvalidPasswordConfirmation() {
        var passwordError: String?
        self.sut.updatePasswordConfirmationValidation = { passwordError = $0 }
        self.sut.passwordConfirmation = "2shor"
        XCTAssertEqual(passwordError, "signup.error.validation.password".localized())
    }

    func testPasswordsDontMatch() {
        var passwordError: String?
        self.sut.updatePasswordMatchingValidation = { passwordError = $0 }
        self.sut.password = "aV@1IdP@ssWord"
        self.sut.passwordConfirmation = "aV@1IdP@ssWordNotMatching"
        XCTAssertEqual(passwordError, "signup.error.validation.password_mismatch".localized())
    }

    func testValidEmailAndPasswords() {
        var emailError: String?
        var passwordError: String?
        var passwordConfirmationError: String?
        var passwordMatchingError: String?
        self.sut.updateEmailValidation = { emailError = $0 }
        self.sut.updatePasswordValidation = { passwordError = $0 }
        self.sut.updatePasswordConfirmationValidation = { passwordConfirmationError = $0 }
        self.sut.updatePasswordMatchingValidation = { passwordMatchingError = $0 }
        self.fillValidCredentials()
        XCTAssertNil(emailError)
        XCTAssertNil(passwordError)
        XCTAssertNil(passwordConfirmationError)
        XCTAssertNil(passwordMatchingError)
    }

    func testSignupCalled() {
        self.fillValidCredentials()
        self.sut.signup()
        XCTAssert(self.sessionManager.signupCalled)
    }

    func testSignupFailed() {
        var didFail = false
        self.fillValidCredentials()
        let error: OMGError = .unexpected(message: "Failed to signup")
        self.sut.onFailedSignup = {
            XCTAssertEqual($0.message, error.message)
            didFail = true
        }
        self.sut.signup()
        self.sessionManager.signupFailure(withError: error)
        XCTAssert(didFail)
    }

    func testSignupSuccess() {
        var didSucceed = false
        self.fillValidCredentials()
        self.sut.onSuccessfulSignup = {
            didSucceed = true
        }
        self.sut.signup()
        self.sessionManager.signupSuccess()
        XCTAssert(didSucceed)
    }

    func testShowLoadingWhenSignup() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        XCTAssertFalse(loadingStatus)
        self.fillValidCredentials()
        self.sut.signup()
        XCTAssertTrue(loadingStatus)
        self.sessionManager.signupSuccess()
        XCTAssertFalse(loadingStatus)
    }

    private func fillValidCredentials() {
        self.sut.email = "email@example.com"
        self.sut.password = "aV@1IdP@ssWord"
        self.sut.passwordConfirmation = "aV@1IdP@ssWord"
    }
}
