//
//  TransactionTableViewCell.swift
//  POSClient
//
//  Created by Mederic Petit on 24/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!

    var transactionCellViewModel: TransactionCellViewModel! {
        didSet {
            self.nameLabel.text = self.transactionCellViewModel.name
            self.timestampLabel.text = self.transactionCellViewModel.timeStamp
            self.amountLabel.text = self.transactionCellViewModel.amount
            self.amountLabel.textColor = self.transactionCellViewModel.color
            self.typeLabel.text = self.transactionCellViewModel.type
        }
    }
}
