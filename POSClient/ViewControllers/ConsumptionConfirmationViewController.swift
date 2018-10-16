//
//  ConsumptionConfirmationViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 16/10/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class ConsumptionConfirmationViewController: BaseViewController {
    var viewModel: ConsumptionConfirmationViewModelProtocol!

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tokenLabel: UILabel!
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var accountNameLabel: UILabel!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var rejectButton: UIButton!

    class func initWithViewModel(_ viewModel: ConsumptionConfirmationViewModelProtocol) -> ConsumptionConfirmationViewController? {
        guard let consumptionConfirmationVC: ConsumptionConfirmationViewController =
            Storyboard.transaction.viewControllerFromId() else { return nil }
        consumptionConfirmationVC.viewModel = viewModel
        return consumptionConfirmationVC
    }

    override func configureView() {
        super.configureView()
        self.titleLabel.text = self.viewModel.title
        self.tokenLabel.text = self.viewModel.amountDisplay
        self.directionLabel.text = self.viewModel.direction
        self.accountNameLabel.text = self.viewModel.accountName
        self.confirmButton.setTitle(self.viewModel.confirmButtonTitle, for: .normal)
        self.rejectButton.setTitle(self.viewModel.rejectButtonTitle, for: .normal)
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onLoadStateChange = { [weak self] in
            $0 ? self?.showLoading() : self?.hideLoading()
        }
        self.viewModel.onSuccessApprove = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        self.viewModel.onSuccessReject = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        self.viewModel.onFailApprove = { [weak self] in
            self?.showError(withMessage: $0.localizedDescription)
        }
        self.viewModel.onFailReject = { [weak self] in
            self?.showError(withMessage: $0.localizedDescription)
        }
    }
}

extension ConsumptionConfirmationViewController {
    @IBAction func tapConfirmButton(_: UIButton) {
        self.viewModel.approve()
    }

    @IBAction func tapRejectButton(_: UIButton) {
        self.viewModel.reject()
    }

    @IBAction func tapCloseButton(_: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
