//
//  SignupConfirmationViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 23/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class SignupConfirmationViewController: BaseViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var hintLabel: UILabel!
    @IBOutlet var gotItButton: UIButton!

    let viewModel: SignupConfirmationViewModel = SignupConfirmationViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appWillEnterForeground),
                                               name: Notification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func configureView() {
        super.configureView()
        self.titleLabel.text = self.viewModel.title
        self.hintLabel.text = self.viewModel.hint
        self.gotItButton.setTitle(self.viewModel.gotItButtonTitle, for: .normal)
        self.gotItButton.addBorder(withColor: Color.omiseGOBlue.uiColor(), width: 1, radius: 4)
    }

    @objc func appWillEnterForeground() {
        self.popToRoot()
    }

    private func popToRoot() {
        self.navigationController?.popToRootViewController(animated: false)
    }
}

extension SignupConfirmationViewController {
    @IBAction func tapGotItButton(_: Any) {
        self.popToRoot()
    }
}
