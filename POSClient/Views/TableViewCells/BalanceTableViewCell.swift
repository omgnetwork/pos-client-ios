//
//  BalanceTableViewCell.swift
//  POSClient
//
//  Created by Mederic Petit on 20/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class BalanceTableViewCell: UITableViewCell {
    @IBOutlet var tokenIconLabel: UILabel!
    @IBOutlet var tokenNameLabel: UILabel!
    @IBOutlet var tokenSymbolLabel: UILabel!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var primaryLabel: UILabel!

    var balanceTableViewModel: BalanceCellViewModel! {
        didSet {
            self.tokenIconLabel.text = self.balanceTableViewModel.tokenIcon
            self.tokenNameLabel.text = self.balanceTableViewModel.tokenName
            self.tokenSymbolLabel.text = self.balanceTableViewModel.tokenSymbol
            self.balanceLabel.text = self.balanceTableViewModel.balanceDisplay
            self.primaryLabel.text = self.balanceTableViewModel.primary
        }
    }
}
