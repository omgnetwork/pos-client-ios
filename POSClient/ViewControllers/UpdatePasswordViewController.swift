//
//  UpdatePasswordViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 15/3/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import TPKeyboardAvoiding

class UpdatePasswordViewController: BaseViewController {
    let showSignupSuccessSegueIdentifier = "showSignupSuccessViewController"

    private var viewModel: UpdatePasswordViewModelProtocol!

    @IBOutlet var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var passwordTextField: OMGFloatingTextField!
    @IBOutlet var passwordConfirmationTextField: OMGFloatingTextField!
    @IBOutlet var passwordHintLabel: UILabel!
    @IBOutlet var updateButton: UIButton!

    class func initWithViewModel(_ viewModel: UpdatePasswordViewModelProtocol) -> UpdatePasswordViewController? {
        guard let updatePasswordVC: UpdatePasswordViewController = Storyboard.login.viewControllerFromId() else { return nil }
        updatePasswordVC.viewModel = viewModel
        return updatePasswordVC
    }

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.title
        self.emailLabel.text = self.viewModel.email

        self.passwordTextField.placeholder = self.viewModel.passwordPlaceholder

        self.passwordConfirmationTextField.placeholder = self.viewModel.passwordConfirmationPlaceholder

        self.updateButton.setTitle(self.viewModel.updateButtonTitle, for: .normal)
    }

    override func configureViewModel() {
        super.configureViewModel()
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
        self.viewModel.onFailedUpdate = { [weak self] in
            self?.showError(withMessage: $0.localizedDescription)
        }
        self.viewModel.onSuccessfulUpdate = { [weak self] in
            self?.showMessage($0)
            self?.dismiss(animated: true, completion: nil)
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

extension UpdatePasswordViewController {
    @IBAction func tapUpdateButton(_: UIButton) {
        self.view.endEditing(true)
        self.viewModel.update()
    }
}

extension UpdatePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !self.scrollView.tpKeyboardAvoiding_focusNextTextField() {
            textField.resignFirstResponder()
            self.viewModel.update()
        }
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let textAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        switch textField {
        case self.passwordTextField: self.viewModel.password = textAfterUpdate
        case self.passwordConfirmationTextField: self.viewModel.passwordConfirmation = textAfterUpdate
        default: break
        }
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        switch textField {
        case self.passwordTextField: self.viewModel.password = ""
        case self.passwordConfirmationTextField: self.viewModel.passwordConfirmation = ""
        default: break
        }
        return true
    }
}
