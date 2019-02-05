//
//  LoginViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 17/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//
import OmiseGO

class LoginViewModel: BaseViewModel, LoginViewModelProtocol {
    // Delegate closures
    var updateEmailValidation: ViewModelValidationClosure?
    var updatePasswordValidation: ViewModelValidationClosure?
    var onFailedLogin: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    let emailPlaceholder = "login.text_field.placeholder.email".localized()
    let passwordPlaceholder = "login.text_field.placeholder.password".localized()
    let loginButtonTitle = "login.button.title.login".localized()
    let registerButtonTitle = "login.button.title.register".localized()
    let currentVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? ""

    var email: String? {
        didSet { self.validateEmail() }
    }

    var password: String? {
        didSet { self.validatePassword() }
    }

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    lazy var isBiometricAvailable: Bool = {
        self.biometric.biometricType() != .none && self.sessionManager.isBiometricAvailable
    }()

    lazy var touchFaceIdButtonTitle = {
        self.biometric.biometricType().name
    }()

    lazy var touchFaceIdButtonPicture: UIImage? = {
        switch self.biometric.biometricType() {
        case .touchID: return UIImage(named: "touch_id_icon")
        case .faceID: return UIImage(named: "face_id_icon")
        default: return nil
        }
    }()

    private let sessionManager: SessionManagerProtocol
    private let biometric = BiometricIDAuth()

    init(sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
        super.init()
    }

    func bioLogin() {
        self.isLoading = true
        self.sessionManager.bioLogin(withPromptMessage: "login.alert.biometric_auth".localized(), success: { [weak self] in
            self?.isLoading = false
        }, failure: { [weak self] _ in
            self?.isLoading = false
        })
    }

    func login() {
        do {
            try self.validateAll()
            self.isLoading = true
            self.submit()
        } catch let error as POSClientError {
            self.onFailedLogin?(error)
        } catch _ {}
    }

    private func submit() {
        let params = LoginParams(email: self.email!, password: self.password!)
        self.sessionManager.login(withParams: params, success: { [weak self] in
            self?.isLoading = false
        }, failure: { [weak self] error in
            self?.isLoading = false
            self?.onFailedLogin?(error)
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
        updatePasswordValidation?(isPasswordValid ? nil : "login.error.validation.password".localized())
        return isPasswordValid
    }

    private func validateAll() throws {
        // We use this syntax to force to go over all validation and don't stop when something is invalid
        // So we can show to the user all fields that have errors
        var isValid = self.validateEmail()
        isValid = self.validatePassword() && isValid
        guard isValid else { throw POSClientError.missingRequiredFields }
    }
}
