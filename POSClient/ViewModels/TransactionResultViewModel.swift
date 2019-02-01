//
//  TransactionResultViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 31/1/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class TransactionResultViewModel: BaseViewModel, TransactionResultViewModelProtocol {
    let status: String
    let amountDisplay: String
    let direction: String
    let accountName: String
    let accountId: String
    let error: String
    let done: String
    let statusImage: UIImage
    let statusImageColor: UIColor

    private let transactionBuilder: TransactionBuilder

    init(transactionBuilder: TransactionBuilder) {
        self.transactionBuilder = transactionBuilder
        let stringifiedAmount =
            OMGNumberFormatter(precision: 5).string(from: transactionBuilder.transactionRequest.amount!,
                                                    subunitToUnit: transactionBuilder.transactionRequest.token.subUnitToUnit)
        self.amountDisplay = "\(stringifiedAmount) \(transactionBuilder.transactionRequest.token.symbol)"
        self.direction = transactionBuilder.transactionRequest.type == .receive ?
            "transaction_result.to".localized() :
            "transaction_result.from".localized()
        self.accountName = transactionBuilder.transactionRequest.account?.name ?? "-"
        self.accountId = transactionBuilder.transactionRequest.account?.id ?? "-"
        self.done = "transaction_result.done".localized()
        if let error = transactionBuilder.error {
            self.statusImage = UIImage(named: "Failed")!
            self.statusImageColor = Color.redError.uiColor()
            self.status = self.transactionBuilder.transactionRequest.type == .receive ?
                "transaction_result.failed_to_send".localized() : "transaction_result.failed_to_receive".localized()
            self.error = error.message
        } else {
            self.statusImage = UIImage(named: "Completed")!
            self.statusImageColor = Color.lightBlue.uiColor()
            self.status = self.transactionBuilder.transactionRequest.type == .receive ?
                "transaction_result.sent".localized() : "transaction_result.received".localized()
            self.error = ""
        }
    }
}
