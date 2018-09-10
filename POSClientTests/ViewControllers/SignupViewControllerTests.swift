//
//  SignupViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 10/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import Toaster
import XCTest

class SignupViewControllerTests: XCTestCase {
    var sut: SignupViewController!

    override func setUp() {
        super.setUp()
        self.sut = Storyboard.signup.storyboard.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        _ = UINavigationController(rootViewController: self.sut)
        _ = self.sut.view
    }

    private func mountOnWindow() {
        let w = UIWindow()
        w.addSubview(self.sut.view)
        w.makeKeyAndVisible()
    }

    override func tearDown() {
        super.tearDown()
        ToastCenter.default.cancelAll()
        self.sut = nil
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.emailTextField.placeholder, self.sut.viewModel.emailPlaceholder)
        XCTAssertEqual(self.sut.passwordTextField.placeholder, self.sut.viewModel.passwordPlaceholder)
        XCTAssertEqual(self.sut.passwordConfirmationTextField.placeholder, self.sut.viewModel.passwordConfirmationPlaceholder)
        XCTAssertEqual(self.sut.signupButton.titleLabel?.text, self.sut.viewModel.signupButtonTitle)
    }

    func testInvalidEmailShowsError() {
        self.sut.viewModel.updateEmailValidation?("qwe")
        XCTAssertEqual(self.sut.emailTextField.errorMessage, "qwe")
    }

    func testInvalidPasswordShowsError() {
        self.sut.viewModel.updatePasswordValidation?("123")
        XCTAssertEqual(self.sut.passwordTextField.errorMessage, "123")
    }

    func testInvalidPasswordConfirmationShowsError() {
        self.sut.viewModel.updatePasswordConfirmationValidation?("456")
        XCTAssertEqual(self.sut.passwordConfirmationTextField.errorMessage, "456")
    }

    func testPasswordsMismatchingShowsError() {
        self.sut.viewModel.updatePasswordMatchingValidation?("789")
        XCTAssertEqual(self.sut.passwordConfirmationTextField.errorMessage, "789")
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

    func testFailedSignupShowsError() {
        let error = POSClientError.unexpected
        self.sut.viewModel.onFailedSignup?(error)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, error.message)
    }

    func testShowConfirmationVCOnSuccessfulSignup() {
        let e = self.expectation(description: "onSuccessfulSignup pushes SignupConfirmationViewController")
        XCTAssertEqual(self.sut.navigationController!.viewControllers.count, 1)
        dispatchMain {
            self.sut.viewModel.onSuccessfulSignup?()
            e.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(self.sut.navigationController!.viewControllers.count, 2)
        XCTAssertTrue(self.sut.navigationController!.viewControllers[1].isKind(of: SignupConfirmationViewController.self))
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

    func testPasswordConfirmationTextFieldChangeUpdatesViewModelPasswordConfirmationAttribute() {
        let range = NSRange(location: 0, length: 0)
        _ = self.sut.textField(self.sut.passwordConfirmationTextField, shouldChangeCharactersIn: range, replacementString: "123")
        XCTAssertEqual(self.sut.viewModel.passwordConfirmation, "123")
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

    func testReturningPasswordTFFocusPasswordConfirmationTF() {
        self.mountOnWindow()
        self.sut.passwordTextField.becomeFirstResponder()
        XCTAssertTrue(self.sut.passwordTextField.isFirstResponder)
        _ = self.sut.textFieldShouldReturn(self.sut.passwordTextField)
        let e = self.expectation(description: "Returning password tf focus password confirmation tf")
        dispatchMain { e.fulfill() }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(self.sut.passwordConfirmationTextField.isFirstResponder)
    }

    func testReturningPasswordConfirmationTFResignFirstResponderAndTriggersSignup() {
        self.mountOnWindow()
        self.sut.passwordConfirmationTextField.becomeFirstResponder()
        XCTAssertTrue(self.sut.passwordConfirmationTextField.isFirstResponder)
        _ = self.sut.textFieldShouldReturn(self.sut.passwordConfirmationTextField)
        let e = self.expectation(description: "Returning password confirmation tf triggers sign up")
        dispatchMain { e.fulfill() }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(self.sut.passwordConfirmationTextField.isFirstResponder)
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

    func testClearPWConfirmationTFClearsViewModelPasswordConfirmation() {
        self.sut.viewModel.passwordConfirmation = "123"
        _ = self.sut.textFieldShouldClear(self.sut.passwordConfirmationTextField)
        XCTAssertEqual(self.sut.viewModel.passwordConfirmation, "")
    }
}
