//
//  LoginViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 17/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import TPKeyboardAvoiding

class LoginViewController: BaseViewController {
    private var viewModel: LoginViewModelProtocol = LoginViewModel()

    @IBOutlet var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet var emailTextField: OMGFloatingTextField!
    @IBOutlet var passwordTextField: OMGFloatingTextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var bioLoginButton: UIButton!
    @IBOutlet var registerButton: UIButton!

    class func initWithViewModel(_ viewModel: LoginViewModelProtocol = LoginViewModel()) -> LoginViewController? {
        guard let loginVC: LoginViewController = Storyboard.login.viewControllerFromId() else { return nil }
        loginVC.viewModel = viewModel
        return loginVC
    }

    override func configureView() {
        super.configureView()
        self.emailTextField.placeholder = self.viewModel.emailPlaceholder
        self.passwordTextField.placeholder = self.viewModel.passwordPlaceholder
        self.loginButton.setTitle(self.viewModel.loginButtonTitle, for: .normal)
        self.registerButton.setTitle(self.viewModel.registerButtonTitle, for: .normal)
        self.setupBioLoginButton()
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.updateEmailValidation = { [weak self] in
            self?.emailTextField.errorMessage = $0
        }
        self.viewModel.updatePasswordValidation = { [weak self] in
            self?.passwordTextField.errorMessage = $0
        }
        self.viewModel.onLoadStateChange = { [weak self] in
            $0 ? self?.showLoading() : self?.hideLoading()
        }
        self.viewModel.onFailedLogin = { [weak self] in
            self?.showError(withMessage: $0.localizedDescription)
        }
    }

    private func setupBioLoginButton() {
        guard self.viewModel.isBiometricAvailable else {
            self.bioLoginButton.isHidden = true
            return
        }
        self.bioLoginButton.setTitle(self.viewModel.touchFaceIdButtonTitle, for: .normal)
        self.bioLoginButton.setImage(self.viewModel.touchFaceIdButtonPicture, for: .normal)
        self.bioLoginButton.addBorder(withColor: Color.omiseGOBlue.uiColor(), width: 1, radius: 4)
    }
}

extension LoginViewController {
    @IBAction func tapLoginButton(_: UIButton) {
        self.view.endEditing(true)
        self.viewModel.login()
    }

    @IBAction func tapBioLoginButton(_: Any) {
        self.view.endEditing(true)
        self.viewModel.bioLogin()
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !self.scrollView.tpKeyboardAvoiding_focusNextTextField() {
            textField.resignFirstResponder()
            self.viewModel.login()
        }
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let textAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        switch textField {
        case self.emailTextField: self.viewModel.email = textAfterUpdate
        case self.passwordTextField: self.viewModel.password = textAfterUpdate
        default: break
        }
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField {
        case self.emailTextField: self.viewModel.email = ""
        case self.passwordTextField: self.viewModel.password = ""
        default: break
        }
        return true
    }
}
