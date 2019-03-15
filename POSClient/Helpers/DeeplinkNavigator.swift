//
//  DeeplinkNavigator.swift
//  POSClient
//
//  Created by Mederic Petit on 22/2/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

struct DeeplinkNavigator {
    func proceedToDeeplink(_ type: Deeplink) {
        switch type {
        case .signupSuccess: self.displayToast(withMessage: "notification.signup_success".localized())
        case let .requestPasswordReset(email: email, token: token):
            self.navigateToResetPasswordVC(withEmail: email, token: token)
        }
    }

    private func displayToast(withMessage message: String) {
        if let vc = UIApplication.shared.keyWindow?.rootViewController as? Toastable {
            vc.showMessage(message)
        }
    }

    private func navigateToResetPasswordVC(withEmail email: String, token: String) {
        if let vc = UIApplication.shared.keyWindow?.rootViewController {
            let viewModel = UpdatePasswordViewModel(email: email, token: token)
            if let viewController = UpdatePasswordViewController.initWithViewModel(viewModel) {
                let navVC = BaseNavigationViewController(rootViewController: viewController)
                vc.present(navVC, animated: false, completion: nil)
            }
        }
    }
}
