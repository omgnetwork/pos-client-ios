//
//  BalanceCellViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 20/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class BalanceCellViewModel: BaseViewModel {
    let tokenIcon: String
    let tokenName: String
    let tokenSymbol: String
    let balanceDisplay: String
    let primary: String
    let balance: Balance

    init(balance: Balance) {
        self.balance = balance
        self.tokenIcon = balance.token.symbol.trunc(length: 3).uppercased()
        self.tokenName = balance.token.name
        self.tokenSymbol = balance.token.symbol
        self.balanceDisplay = balance.displayAmount(withPrecision: 2)
        self.primary = balance.token.id == PrimaryTokenManager().getPrimaryTokenId() ?
            "balance_cell.label.primary".localized() :
            ""
    }
}
