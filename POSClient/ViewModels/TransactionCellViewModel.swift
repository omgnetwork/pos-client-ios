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
    let type: String
    let timeStamp: String
    let amount: String
    let color: UIColor
    let statusText: String
    let statusColor: UIColor
    let statusImage: UIImage?

    init(transaction: Transaction, currentUserAddress: String) {
        self.transaction = transaction
        var source: TransactionSource!
        var sign: String!
        if currentUserAddress == transaction.from.address {
            self.type = "transactions.label.debit".localized()
            self.color = Color.transactionDebitRed.uiColor()
            self.name = transaction.to.account?.name ?? transaction.to.user?.email ?? "-"
            source = transaction.from
            sign = "-"
        } else {
            self.type = "transactions.label.topup".localized()
            self.color = Color.transactionCreditGreen.uiColor()
            self.name = transaction.from.account?.name ?? transaction.from.user?.email ?? "-"
            source = transaction.to
            sign = "+"
        }
        switch transaction.status {
        case .approved: self.statusText = "transactions.label.status.approved".localized()
        case .confirmed: self.statusText = "transactions.label.status.confirmed".localized()
        case .expired: self.statusText = "transactions.label.status.expired".localized()
        case .failed: self.statusText = "transactions.label.status.failed".localized()
        case .pending: self.statusText = "transactions.label.status.pending".localized()
        case .rejected: self.statusText = "transactions.label.status.rejected".localized()
        }

        switch transaction.status {
        case .confirmed:
            self.statusColor = Color.transactionCreditGreen.uiColor()
            self.statusImage = UIImage(named: "checkmark_icon")
        default:
            self.statusColor = Color.transactionDebitRed.uiColor()
            self.statusImage = UIImage(named: "cross_icon")
        }
        let displayableAmount = OMGNumberFormatter(precision: 2).string(from: source.amount, subunitToUnit: source.token.subUnitToUnit)
        amount = "\(sign!) \(displayableAmount) \(source.token.symbol)"
        timeStamp = "\(transaction.createdAt.toString(withFormat: "MMM dd, HH:mm")) :"
    }
}
