//
//  UpdatePasswordViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 15/3/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class UpdatePasswordViewModel: BaseViewModel, UpdatePasswordViewModelProtocol {
    // Delegate closures
    var updatePasswordValidation: ViewModelValidationClosure?
    var updatePasswordConfirmationValidation: ViewModelValidationClosure?
    var updatePasswordMatchingValidation: ViewModelValidationClosure?
    var onSuccessfulUpdate: ObjectClosure<String>?
    var onFailedUpdate: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    let title = "update_password.view.title".localized()

    let email: String
    let token: String

    let passwordPlaceholder = "update_password.text_field.placeholder.password".localized()
    let passwordConfirmationPlaceholder = "update_password.text_field.placeholder.password_confirmation".localized()
    let passwordHint = "update_password.label.password_hint".localized()
    let updateButtonTitle = "update_password.button.title.update".localized()

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
        didSet { self.onLoadStateChange?(self.isLoading) }
    }

    private let forgetPasswordWrapper: ForgetPasswordWrapperProtocol
    private let sessionManager: SessionManagerProtocol

    init(email: String,
         token: String,
         forgetPasswordWrapper: ForgetPasswordWrapperProtocol = ForgetPasswordWrapper(),
         sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.email = email
        self.token = token
        self.forgetPasswordWrapper = forgetPasswordWrapper
        self.sessionManager = sessionManager
        super.init()
    }

    func update() {
        do {
            try self.validateAll()
            self.submit()
        } catch let error as POSClientError {
            self.onFailedUpdate?(error)
        } catch _ {}
    }

    private func submit() {
        self.isLoading = true
        let params = UserUpdatePasswordParams(email: self.email,
                                              token: self.token,
                                              password: self.password!,
                                              passwordConfirmation: self.passwordConfirmation!)
        self.forgetPasswordWrapper.update(withParams: params) { [weak self] result in
            switch result {
            case .success:
                self?.sessionManager.logout(true, success: nil, failure: nil)
                self?.onSuccessfulUpdate?("update_password.success".localized())
            case let .failure(error): self?.onFailedUpdate?(POSClientError.omiseGO(error: error))
                self?.isLoading = false
            }
        }
    }

    @discardableResult
    private func validatePassword() -> Bool {
        let isPasswordValid = self.password?.isValidPassword() ?? false
        updatePasswordValidation?(isPasswordValid ? nil : "update_password.error.validation.password".localized())
        return isPasswordValid
    }

    @discardableResult
    private func validatePasswordConfirmation() -> Bool {
        let isPasswordValid = self.passwordConfirmation?.isValidPassword() ?? false
        updatePasswordConfirmationValidation?(isPasswordValid ? nil : "update_password.error.validation.password".localized())
        return isPasswordValid
    }

    @discardableResult
    private func validatePasswordMatch() -> Bool {
        let arePasswordMatching = self.password == self.passwordConfirmation && self.password != nil && !self.password!.isEmpty
        updatePasswordMatchingValidation?(arePasswordMatching ? nil : "update_password.error.validation.password_mismatch".localized())
        return arePasswordMatching
    }

    private func validateAll() throws {
        var error: POSClientError?
        if !self.validatePasswordMatch() {
            error = POSClientError.message(message: "update_password.error.validation.password_mismatch".localized())
        }
        if !self.validatePasswordConfirmation() {
            error = POSClientError.message(message: "update_password.error.validation.password.full".localized())
        }
        if !self.validatePassword() {
            error = POSClientError.message(message: "update_password.error.validation.password.full".localized())
        }
        if let e = error { throw e }
    }
}
