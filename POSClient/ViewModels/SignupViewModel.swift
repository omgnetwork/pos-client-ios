//
//  SignupViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 22/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class SignupViewModel: BaseViewModel {
    // Delegate closures
    var updateEmailValidation: ViewModelValidationClosure?
    var updatePasswordValidation: ViewModelValidationClosure?
    var updatePasswordConfirmationValidation: ViewModelValidationClosure?
    var updatePasswordMatchingValidation: ViewModelValidationClosure?
    var onSuccessfulSignup: EmptyClosure?
    var onFailedSignup: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    let title = "signup.view.title".localized()

    let emailPlaceholder = "signup.text_field.placeholder.email".localized()
    let passwordPlaceholder = "signup.text_field.placeholder.password".localized()
    let passwordConfirmationPlaceholder = "signup.text_field.placeholder.password_confirmation".localized()
    let passwordHint = "signup.label.password_hint".localized()
    let terms = "signup.label.terms".localized()
    let registerButtonTitle = "signup.button.title.signup".localized()

    var email: String? {
        didSet { self.validateEmail() }
    }

    var password: String? {
        didSet {
            if self.validatePassword() {
                self.validatePasswordMatch()
            }
        }
    }

    var passwordConfirmation: String? {
        didSet {
            if self.validatePasswordConfirmation() {
                self.validatePasswordMatch()
            }
        }
    }

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    private let sessionManager: SessionManagerProtocol

    init(sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
        super.init()
    }

    func signup() {
        do {
            try self.validateAll()
            self.isLoading = true
            self.submit()
        } catch let error as POSClientError {
            self.onFailedSignup?(error)
        } catch _ {}
    }

    private func submit() {
        let params = SignupParams(email: self.email!,
                                  password: self.password!,
                                  passwordConfirmation: self.passwordConfirmation!,
                                  successURL: Constant.urlScheme)
        self.sessionManager.signup(withParams: params, success: { [weak self] in
            self?.isLoading = false
            self?.onSuccessfulSignup?()
        }, failure: { [weak self] error in
            self?.isLoading = false
            self?.onFailedSignup?(error)
        })
    }

    @discardableResult
    private func validateEmail() -> Bool {
        let isEmailValid = self.email?.isValidEmailAddress() ?? false
        self.updateEmailValidation?(isEmailValid ? nil : "login.error.validation.email".localized())
        return isEmailValid
    }

    @discardableResult
    private func validatePassword() -> Bool {
        let isPasswordValid = self.password?.isValidPassword() ?? false
        updatePasswordValidation?(isPasswordValid ? nil : "signup.error.validation.password".localized())
        return isPasswordValid
    }

    @discardableResult
    private func validatePasswordConfirmation() -> Bool {
        let isPasswordValid = self.passwordConfirmation?.isValidPassword() ?? false
        updatePasswordConfirmationValidation?(isPasswordValid ? nil : "signup.error.validation.password".localized())
        return isPasswordValid
    }

    @discardableResult
    private func validatePasswordMatch() -> Bool {
        let arePasswordMatching = self.password == self.passwordConfirmation && self.password != nil && !self.password!.isEmpty
        updatePasswordMatchingValidation?(arePasswordMatching ? nil : "register.error.validation.password_mismatch".localized())
        return arePasswordMatching
    }

    private func validateAll() throws {
        // We use this syntax to force to go over all validation and don't stop when something is invalid
        // So we can show to the user all fields that have errors
        var isValid = self.validateEmail()
        isValid = self.validatePassword() && isValid
        isValid = self.validatePasswordConfirmation() && isValid
        isValid = self.validatePasswordMatch() && isValid
        guard isValid else { throw POSClientError.missingRequiredFields }
    }
}
