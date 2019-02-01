//
//  TransactionConfirmationViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 31/1/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class TransactionConfirmationViewController: BaseViewController {
    var viewModel: TransactionConfirmationViewModelProtocol!
    private let showTransactionResultSegueId = "showTransactionResultSegueIdentifier"
    private let showPendingConfirmationSegueId = "showPendingConfirmationSegueIdentifier"

    @IBOutlet var tokenLabel: UILabel!
    @IBOutlet var directionLabel: UILabel!
    @IBOutlet var accountNameLabel: UILabel!
    @IBOutlet var accountIdLabel: UILabel!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet var cancelButton: UIButton!

    class func initWithViewModel(_ viewModel: TransactionConfirmationViewModelProtocol) -> TransactionConfirmationViewController? {
        guard let transactionConfirmationVC: TransactionConfirmationViewController =
            Storyboard.transaction.viewControllerFromId() else { return nil }
        transactionConfirmationVC.viewModel = viewModel
        return transactionConfirmationVC
    }

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.title
        self.tokenLabel.text = self.viewModel.amountDisplay
        self.directionLabel.text = self.viewModel.direction
        self.accountNameLabel.text = self.viewModel.accountName
        self.accountIdLabel.text = self.viewModel.accountId
        self.confirmButton.setTitle(self.viewModel.confirm, for: .normal)
        self.cancelButton.setTitle(self.viewModel.cancel, for: .normal)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.cancelButton.addBorder(withColor: Color.redError.uiColor(), width: 1, radius: 4)
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onLoadStateChange = { [weak self] in
            $0 ? self?.showLoading() : self?.hideLoading()
        }
        self.viewModel.onPendingConsumptionConfirmation = { [weak self] in
            guard let self = self else { return }
            self.performSegue(withIdentifier: self.showPendingConfirmationSegueId, sender: nil)
        }
        self.viewModel.onCompletedConsumption = { [weak self] transactionBuilder in
            guard let self = self else { return }
            self.viewModel.stopListening()
            if let viewController = self.presentedViewController, !viewController.isBeingDismissed {
                viewController.dismiss(animated: true, completion: {
                    self.performSegue(withIdentifier: self.showTransactionResultSegueId, sender: transactionBuilder)
                })
            } else {
                self.performSegue(withIdentifier: self.showTransactionResultSegueId, sender: transactionBuilder)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.showTransactionResultSegueId,
            let transactionResultVC = segue.destination as? TransactionResultViewController,
            let transactionBuilder = sender as? TransactionBuilder {
            transactionResultVC.viewModel = TransactionResultViewModel(transactionBuilder: transactionBuilder)
        } else if segue.identifier == self.showPendingConfirmationSegueId,
            let vc = segue.destination as? WaitingForUserConfirmationViewController {
            vc.delegate = self.viewModel
        }
    }
}

extension TransactionConfirmationViewController {
    @IBAction func tapConfirmButton(_: UIButton) {
        self.viewModel.consume()
    }

    @IBAction func tapCancelButton(_: UIButton) {
        self.viewModel.stopListening()
        self.navigationController?.popViewController(animated: true)
    }
}
