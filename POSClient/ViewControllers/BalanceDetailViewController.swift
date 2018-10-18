//
//  BalanceDetailViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 20/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class BalanceDetailViewController: BaseViewController {
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var tokenSymbolLabel: UILabel!
    @IBOutlet var payButton: UIButton!
    @IBOutlet var lastUpdatedLabel: UILabel!
    @IBOutlet var lastUpdatedValueLabel: UILabel!
    @IBOutlet var setPrimaryButton: UIButton!

    var viewModel: BalanceDetailViewModelProtocol!

    class func initWithViewModel(_ viewModel: BalanceDetailViewModelProtocol = BalanceDetailViewModel()) -> BalanceDetailViewController? {
        guard let balanceDetailVC: BalanceDetailViewController = Storyboard.balance.viewControllerFromId() else { return nil }
        balanceDetailVC.viewModel = viewModel
        return balanceDetailVC
    }

    override func configureView() {
        super.configureView()
        self.balanceLabel.text = self.viewModel.balanceDisplay
        self.tokenSymbolLabel.text = self.viewModel.tokenSymbol
        self.lastUpdatedLabel.text = self.viewModel.lastUpdatedString
        self.lastUpdatedValueLabel.text = self.viewModel.lastUpdated
        self.title = self.viewModel.title
        self.payButton.titleLabel?.numberOfLines = 0
        self.payButton.setAttributedTitle(self.viewModel.payOrTopupAttrStr, for: .normal)
        self.updatePrimaryButton()
        self.viewModel.loadData()
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onDataUpdate = { [weak self] in
            self?.balanceLabel.text = self?.viewModel.balanceDisplay
            self?.tokenSymbolLabel.text = self?.viewModel.tokenSymbol
            self?.title = self?.viewModel.title
        }
        self.viewModel.onFailGetWallet = { [weak self] in
            self?.showError(withMessage: $0.localizedDescription)
        }
        self.viewModel.onLoadStateChange = { [weak self] in
            $0 ? self?.showLoading() : self?.hideLoading()
        }
        self.viewModel.onPrimaryStateChange = { [weak self] in
            self?.updatePrimaryButton()
        }
    }

    deinit {
        self.viewModel.stopObserving()
    }

    private func updatePrimaryButton() {
        self.setPrimaryButton.setTitle(self.viewModel.setPrimaryButtonTitle, for: .normal)
        self.setPrimaryButton.alpha = self.viewModel.isPrimary ? 0.5 : 1
        self.setPrimaryButton.isEnabled = !self.viewModel.isPrimary
    }
}

extension BalanceDetailViewController {
    @IBAction func tapSetPrimaryButton(_: Any) {
        self.viewModel.setPrimary()
    }

    @IBAction func tapPayOrTopupButton(_: Any) {
        NotificationCenter.default.post(name: Notification.Name.didTapPayOrTopup, object: nil)
    }

    @IBAction func tapRefreshIcon(_: Any) {
        self.viewModel.loadData()
    }
}
