//
//  SignupViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 22/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import TPKeyboardAvoiding

class SignupViewController: BaseViewController {
    let showSignupSuccessSegueIdentifier = "showSignupSuccessViewController"

    let viewModel: SignupViewModel = SignupViewModel()

    @IBOutlet var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet var emailTextField: OMGFloatingTextField!
    @IBOutlet var passwordTextField: OMGFloatingTextField!
    @IBOutlet var passwordConfirmationTextField: OMGFloatingTextField!
    @IBOutlet var passwordHintLabel: UILabel!
    @IBOutlet var termsLabel: UILabel!
    @IBOutlet var signupButton: UIButton!

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.title
        self.emailTextField.placeholder = self.viewModel.emailPlaceholder
        self.passwordTextField.placeholder = self.viewModel.passwordPlaceholder
        self.passwordConfirmationTextField.placeholder = self.viewModel.passwordConfirmationPlaceholder
        self.signupButton.setTitle(self.viewModel.registerButtonTitle, for: .normal)
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.updateEmailValidation = { [weak self] in
            self?.emailTextField.errorMessage = $0
        }
        self.viewModel.updatePasswordValidation = { [weak self] in
            self?.passwordTextField.errorMessage = $0
        }
        self.viewModel.updatePasswordConfirmationValidation = { [weak self] in
            self?.passwordConfirmationTextField.errorMessage = $0
        }
        self.viewModel.updatePasswordMatchingValidation = { [weak self] in
            self?.passwordConfirmationTextField.errorMessage = $0
        }
        self.viewModel.onLoadStateChange = { [weak self] in
            $0 ? self?.showLoading() : self?.hideLoading()
        }
        self.viewModel.onFailedSignup = { [weak self] in
            self?.showError(withMessage: $0.localizedDescription)
        }
        self.viewModel.onSuccessfulSignup = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.performSegue(withIdentifier: weakSelf.showSignupSuccessSegueIdentifier, sender: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}

extension SignupViewController {
    @IBAction func tapSignupButton(_: UIButton) {
        self.view.endEditing(true)
        self.viewModel.signup()
    }
}

extension SignupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !self.scrollView.tpKeyboardAvoiding_focusNextTextField() {
            textField.resignFirstResponder()
            self.viewModel.signup()
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
        case self.passwordConfirmationTextField: self.viewModel.passwordConfirmation = textAfterUpdate
        default: break
        }
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField {
        case self.emailTextField: self.viewModel.email = ""
        case self.passwordTextField: self.viewModel.password = ""
        case self.passwordConfirmationTextField: self.viewModel.passwordConfirmation = ""
        default: break
        }
        return true
    }
}
