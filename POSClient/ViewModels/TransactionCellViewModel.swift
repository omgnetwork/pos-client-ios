//
//  TransactionCellViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 24/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import BigInt
import OmiseGO

class TransactionCellViewModel: BaseViewModel {
    private let transaction: Transaction!

    let name: String
    let timeStamp: String
    let amount: String
    let color: UIColor
    let statusText: String
    let statusImage: UIImage?

    init(transaction: Transaction, currentUserAddress: String) {
        self.transaction = transaction
        var source: TransactionSource!
        var sign: String!
        if currentUserAddress == transaction.from.address {
            self.color = Color.redError.uiColor()
            self.name = transaction.to.account?.name ?? transaction.to.user?.email ?? "-"
            source = transaction.from
            sign = "-"
        } else {
            self.color = Color.transactionCreditGreen.uiColor()
            self.name = transaction.from.account?.name ?? transaction.from.user?.email ?? "-"
            source = transaction.to
            sign = "+"
        }
        switch transaction.status {
        case .confirmed:
            self.statusImage = UIImage(named: "checkmark_icon")
            self.statusText = "transactions.label.status.success".localized()
        default:
            self.statusImage = UIImage(named: "cross_icon")
            self.statusText = "transactions.label.status.failure".localized()
        }
        let displayableAmount = OMGNumberFormatter(precision: 2).string(from: source.amount, subunitToUnit: source.token.subUnitToUnit)
        amount = "\(sign!) \(displayableAmount) \(source.token.symbol)"
        timeStamp = transaction.createdAt.toString(withFormat: "MMM dd, HH:mm")
    }
}
