//
//  SignupViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 10/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import SBToaster
import XCTest

class SignupViewControllerTests: XCTestCase {
    var sut: SignupViewController!
    var viewModel: TestSignupViewModel!

    override func setUp() {
        super.setUp()
        self.viewModel = TestSignupViewModel()
        self.sut = SignupViewController.initWithViewModel(self.viewModel)
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
        self.viewModel = nil
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.emailTextField.placeholder, "x")
        XCTAssertEqual(self.sut.passwordTextField.placeholder, "x")
        XCTAssertEqual(self.sut.passwordConfirmationTextField.placeholder, "x")
        XCTAssertEqual(self.sut.signupButton.titleLabel?.text, "x")
    }

    func testInvalidEmailShowsError() {
        self.viewModel.updateEmailValidation?("qwe")
        XCTAssertEqual(self.sut.emailTextField.errorMessage, "qwe")
    }

    func testInvalidPasswordShowsError() {
        self.viewModel.updatePasswordValidation?("123")
        XCTAssertEqual(self.sut.passwordTextField.errorMessage, "123")
    }

    func testInvalidPasswordConfirmationShowsError() {
        self.viewModel.updatePasswordConfirmationValidation?("456")
        XCTAssertEqual(self.sut.passwordConfirmationTextField.errorMessage, "456")
    }

    func testPasswordsMismatchingShowsError() {
        self.viewModel.updatePasswordMatchingValidation?("789")
        XCTAssertEqual(self.sut.passwordConfirmationTextField.errorMessage, "789")
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

    func testFailedSignupShowsError() {
        let error = POSClientError.unexpected
        self.viewModel.onFailedSignup?(error)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, error.message)
    }

    func testShowConfirmationVCOnSuccessfulSignup() {
        let e = self.expectation(description: "onSuccessfulSignup pushes SignupConfirmationViewController")
        XCTAssertEqual(self.sut.navigationController!.viewControllers.count, 1)
        dispatchMain {
            self.viewModel.onSuccessfulSignup?()
            e.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(self.sut.navigationController!.viewControllers.count, 2)
        XCTAssertTrue(self.sut.navigationController!.viewControllers[1].isKind(of: SignupConfirmationViewController.self))
    }

    func testTapSignupButtonTriggersSignupAndResignFirstResponder() {
        self.mountOnWindow()
        self.sut.emailTextField.becomeFirstResponder()
        XCTAssertTrue(self.sut.emailTextField.isFirstResponder)
        self.sut.tapSignupButton(self.sut.signupButton)
        let e = self.expectation(description: "Tap on sign up button resigns first responder and trigger sign up")
        dispatchMain { e.fulfill() }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(self.sut.emailTextField.isFirstResponder)
        XCTAssertTrue(self.viewModel.isSignupCalled)
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

    func testPasswordConfirmationTextFieldChangeUpdatesViewModelPasswordConfirmationAttribute() {
        let range = NSRange(location: 0, length: 0)
        _ = self.sut.textField(self.sut.passwordConfirmationTextField, shouldChangeCharactersIn: range, replacementString: "123")
        XCTAssertEqual(self.viewModel.passwordConfirmation, "123")
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
        XCTAssertTrue(self.viewModel.isSignupCalled)
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

    func testClearPWConfirmationTFClearsViewModelPasswordConfirmation() {
        self.viewModel.passwordConfirmation = "123"
        _ = self.sut.textFieldShouldClear(self.sut.passwordConfirmationTextField)
        XCTAssertEqual(self.viewModel.passwordConfirmation, "")
    }
}
