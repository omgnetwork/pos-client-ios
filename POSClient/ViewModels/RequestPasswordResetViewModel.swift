//
//  RequestPasswordResetViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 15/3/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class RequestPasswordResetViewModel: BaseViewModel, RequestPasswordResetViewModelProtocol {
    // Delegate closures
    var updateEmailValidation: ViewModelValidationClosure?
    var onSuccessRequest: ObjectClosure<String>?
    var onFailedRequest: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    let title = "request_password_reset.view.title".localized()
    let emailPlaceholder = "request_password_reset.text_field.placeholder.email".localized()
    let requestButtonTitle = "request_password_reset.button.title.request".localized()
    let hintString = "request_password_reset.label.hint".localized()

    var email: String? {
        didSet { self.validateEmail() }
    }

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(self.isLoading) }
    }

    private let forgetPasswordWrapper: ForgetPasswordWrapperProtocol
    private let sessionManager: SessionManagerProtocol

    init(forgetPasswordWrapper: ForgetPasswordWrapperProtocol = ForgetPasswordWrapper(),
         sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.forgetPasswordWrapper = forgetPasswordWrapper
        self.sessionManager = sessionManager
        super.init()
    }

    func requestReset() {
        do {
            try self.validateAll()
            self.isLoading = true
            self.submit()
        } catch let error as POSClientError {
            self.onFailedRequest?(error)
        } catch _ {}
    }

    private func submit() {
        let resetPasswordURL = UserResetPasswordParams.defaultResetPasswordURL(forClient: self.sessionManager.httpClient)
        let params = UserResetPasswordParams(email: self.email!,
                                             resetPasswordURL: resetPasswordURL,
                                             forwardURL: Constant.urlScheme + Constant.resetPasswordForwardURLpath)
        self.forgetPasswordWrapper.requestReset(withParams: params) { [weak self] result in
            switch result {
            case .success: self?.onSuccessRequest?("request_password_reset.success".localized())
            case let .failure(error): self?.onFailedRequest?(POSClientError.omiseGO(error: error))
            }
            self?.isLoading = false
        }
    }

    @discardableResult
    private func validateEmail() -> Bool {
        let isEmailValid = self.email?.isValidEmailAddress() ?? false
        updateEmailValidation?(isEmailValid ? nil : "request_password_reset.error.validation.email".localized())
        return isEmailValid
    }

    private func validateAll() throws {
        guard self.validateEmail() else { throw POSClientError.message(message: "request_password_reset.error.validation".localized()) }
    }
}
