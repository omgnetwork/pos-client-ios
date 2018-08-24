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
    let status: String

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
        var statusText: String!
        switch transaction.status {
        case .approved: statusText = "transactions.label.status.approved".localized()
        case .confirmed: statusText = "transactions.label.status.confirmed".localized()
        case .expired: statusText = "transactions.label.status.expired".localized()
        case .failed: statusText = "transactions.label.status.failed".localized()
        case .pending: statusText = "transactions.label.status.pending".localized()
        case .rejected: statusText = "transactions.label.status.rejected".localized()
        }
        self.status = "- \(statusText!)"
        let displayableAmount = OMGNumberFormatter(precision: 2).string(from: source.amount, subunitToUnit: source.token.subUnitToUnit)
        amount = "\(sign!) \(displayableAmount) \(source.token.symbol)"
        timeStamp = transaction.createdAt.toString(withFormat: "MMM dd, HH:mm")
    }
}
