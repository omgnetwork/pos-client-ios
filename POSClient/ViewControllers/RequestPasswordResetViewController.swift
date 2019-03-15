//
//  RequestPasswordResetViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 15/3/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class RequestPasswordResetViewController: BaseViewController {
    private var viewModel: RequestPasswordResetViewModelProtocol = RequestPasswordResetViewModel()

    @IBOutlet var hintLabel: UILabel!
    @IBOutlet var emailTextField: OMGFloatingTextField!
    @IBOutlet var submitButton: UIButton!

    class func initWithViewModel(_ viewModel: RequestPasswordResetViewModelProtocol = RequestPasswordResetViewModel())
        -> RequestPasswordResetViewController? {
        guard let requestPasswordResetVC: RequestPasswordResetViewController = Storyboard.login.viewControllerFromId()
        else { return nil }
        requestPasswordResetVC.viewModel = viewModel
        return requestPasswordResetVC
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func configureView() {
        super.configureView()
        self.navigationItem.title = self.viewModel.title

        self.emailTextField.placeholder = self.viewModel.emailPlaceholder

        self.submitButton.setTitle(self.viewModel.requestButtonTitle, for: .normal)

        self.hintLabel.text = self.viewModel.hintString
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.updateEmailValidation = { [weak self] in
            self?.emailTextField.errorMessage = $0
        }
        self.viewModel.onLoadStateChange = { [weak self] in
            $0 ? self?.showLoading() : self?.hideLoading()
        }
        self.viewModel.onFailedRequest = { [weak self] in
            self?.showError(withMessage: $0.localizedDescription)
        }
        self.viewModel.onSuccessRequest = { [weak self] in
            self?.showMessage($0)
            self?.navigationController?.popViewController(animated: true)
        }
    }
}

extension RequestPasswordResetViewController {
    @IBAction func tapSubmitButton(_: UIButton) {
        self.view.endEditing(true)
        self.viewModel.requestReset()
    }
}

extension RequestPasswordResetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.viewModel.requestReset()
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        let textAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        self.viewModel.email = textAfterUpdate
        return true
    }

    func textFieldShouldClear(_: UITextField) -> Bool {
        self.viewModel.email = ""
        return true
    }
}
