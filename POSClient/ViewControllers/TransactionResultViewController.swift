//
//  TransactionResultViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 31/1/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class TransactionResultViewController: BaseViewController {
    var viewModel: TransactionResultViewModelProtocol!

    @IBOutlet var tokenLabel: UILabel!
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var accountNameLabel: UILabel!
    @IBOutlet var accountIdLabel: UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var statusImageView: UIImageView!

    class func initWithViewModel(_ viewModel: TransactionResultViewModelProtocol) -> TransactionResultViewController? {
        guard let transactionResultVC: TransactionResultViewController =
            Storyboard.qrCode.viewControllerFromId() else { return nil }
        transactionResultVC.viewModel = viewModel
        return transactionResultVC
    }

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.status
        self.tokenLabel.text = self.viewModel.amountDisplay
        self.directionLabel.text = self.viewModel.direction
        self.accountNameLabel.text = self.viewModel.accountName
        self.accountIdLabel.text = self.viewModel.accountId
        self.errorLabel.text = self.viewModel.error
        self.doneButton.setTitle(self.viewModel.done, for: .normal)
        self.statusImageView.image = self.viewModel.statusImage
        self.statusImageView.tintColor = self.viewModel.statusImageColor
    }

    override func configureViewModel() {
        super.configureViewModel()
    }

    @IBAction func tapDoneButton(_: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
