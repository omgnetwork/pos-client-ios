//
//  ProfileTableViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 23/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class ProfileTableViewController: BaseTableViewController {
    let transactionsSegueIdentifier = "showTransactionViewController"
    @IBOutlet var transactionLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var emailValueLabel: UILabel!
    @IBOutlet var touchFaceIdLabel: UILabel!
    @IBOutlet var touchFaceIdSwitch: UISwitch!
    @IBOutlet var signOutLabel: UILabel!

    let viewModel = ProfileTableViewModel()

    override func configureView() {
        super.configureView()
        self.navigationItem.title = self.viewModel.title
        self.transactionLabel.text = self.viewModel.transactionLabelText
        self.emailLabel.text = self.viewModel.emailLabelText
        self.emailValueLabel.text = self.viewModel.emailValueLabelText
        self.touchFaceIdLabel.text = self.viewModel.touchFaceIdLabelText
        self.touchFaceIdSwitch.isOn = self.viewModel.switchState
        self.signOutLabel.text = self.viewModel.signOutLabelText
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onFailLogout = { [weak self] in
            self?.showError(withMessage: $0.message)
        }
        self.viewModel.onLoadStateChange = { [weak self] in
            $0 ? self?.showLoading() : self?.hideLoading()
        }
    }
}

extension ProfileTableViewController {
    @IBAction func didUpdateSwitch(sw: UISwitch) {
        self.viewModel.toggleSwitch(newValue: sw.isOn)
    }
}

extension ProfileTableViewController {
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0): // transactions
            self.performSegue(withIdentifier: self.transactionsSegueIdentifier, sender: nil)
        case (2, 0): // Sign out
            self.viewModel.logout()
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (1, 1) where !self.viewModel.isBioEnable: return 0
        default: return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}
