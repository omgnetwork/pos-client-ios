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
    let touchIdConfirmationSegueIdentifier = "showTouchIdConfirmationViewController"
    @IBOutlet var transactionLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var emailValueLabel: UILabel!
    @IBOutlet var touchFaceIdLabel: UILabel!
    @IBOutlet var touchFaceIdSwitch: UISwitch!
    @IBOutlet var signOutLabel: UILabel!
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var versionValueLabel: UILabel!

    private var viewModel: ProfileTableViewModelProtocol = ProfileTableViewModel()

    class func initWithViewModel(_ viewModel: ProfileTableViewModelProtocol = ProfileTableViewModel()) -> ProfileTableViewController? {
        guard let profileVC: ProfileTableViewController = Storyboard.profile.viewControllerFromId() else { return nil }
        profileVC.viewModel = viewModel
        return profileVC
    }

    override func configureView() {
        super.configureView()
        self.navigationItem.title = self.viewModel.title
        self.transactionLabel.text = self.viewModel.transactionLabelText
        self.emailLabel.text = self.viewModel.emailLabelText
        self.emailValueLabel.text = self.viewModel.emailValueLabelText
        self.touchFaceIdLabel.text = self.viewModel.touchFaceIdLabelText
        self.touchFaceIdSwitch.isOn = self.viewModel.switchState
        self.signOutLabel.text = self.viewModel.signOutLabelText
        self.versionLabel.text = self.viewModel.versionLabelText
        self.versionValueLabel.text = self.viewModel.currentVersion
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onFailLogout = { [weak self] in
            self?.showError(withMessage: $0.message)
        }
        self.viewModel.onLoadStateChange = { [weak self] in
            $0 ? self?.showLoading() : self?.hideLoading()
        }
        self.viewModel.shouldShowEnableConfirmationView = { [weak self] in
            guard let self = self else { return }
            self.performSegue(withIdentifier: self.touchIdConfirmationSegueIdentifier, sender: nil)
        }
        self.viewModel.onBioStateChange = { [weak self] isEnabled in
            self?.touchFaceIdSwitch.isOn = isEnabled
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.touchFaceIdSwitch.isOn = self.viewModel.switchState
    }

    deinit {
        self.viewModel.stopObserving()
    }
}

extension ProfileTableViewController {
    @IBAction func didUpdateSwitch(_ sender: UISwitch) {
        self.viewModel.toggleSwitch(newValue: sender.isOn)
    }
}

extension ProfileTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        switch (indexPath.section, indexPath.row) {
        case (1, 0) where !self.viewModel.isBiometricAvailable: // Email
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        default: break
        }
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0): // transactions
            self.performSegue(withIdentifier: self.transactionsSegueIdentifier, sender: nil)
        case (3, 0): // Sign out
            self.viewModel.logout()
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (1, 1) where !self.viewModel.isBiometricAvailable: return 0
        default: return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    override func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1: return self.viewModel.settingsSectionTitle
        case 2: return self.viewModel.infoSectionTitle
        default:
            return nil
        }
    }
}
