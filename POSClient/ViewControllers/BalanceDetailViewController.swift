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

    let viewModel: BalanceDetailViewModel = BalanceDetailViewModel()

    func setup(withBalance balance: Balance) {
        self.viewModel.balance = balance
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
    }

    override func configureViewModel() {
        super.configureViewModel()

        self.viewModel.onDataUpdate = {
            self.balanceLabel.text = self.viewModel.balanceDisplay
            self.tokenSymbolLabel.text = self.viewModel.tokenSymbol
            self.title = self.viewModel.title
        }
        self.viewModel.onFailGetWallet = {
            self.showError(withMessage: $0.localizedDescription)
        }
        self.viewModel.onLoadStateChange = { $0 ? self.showLoading() : self.hideLoading() }
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}

extension BalanceDetailViewController {
    @IBAction func DidTapPayButton(_: UIButton) {
    }
}
