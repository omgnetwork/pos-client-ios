//
//  PrimaryTokenManager.swift
//  POSClient
//
//  Created by Mederic Petit on 18/10/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class PrimaryTokenManager {
    let userDefaultsWrapper = UserDefaultsWrapper()

    func getPrimaryTokenId() -> String? {
        return self.userDefaultsWrapper.getValue(forKey: .primaryBalance)
    }

    func setPrimary(tokenId: String) {
        self.userDefaultsWrapper.storeValue(value: tokenId, forKey: .primaryBalance)
        self.userDefaultsWrapper.clearValue(forKey: .transactionRequestsQRString)
        NotificationCenter.default.post(name: .onPrimaryTokenUpdate, object: tokenId)
    }

    func clear() {
        self.userDefaultsWrapper.clearValue(forKey: .transactionRequestsQRString)
        self.userDefaultsWrapper.clearValue(forKey: .primaryBalance)
    }

    func setDefaultPrimaryIfNeeded(withWallet wallet: Wallet?) {
        if self.userDefaultsWrapper.getValue(forKey: .primaryBalance) == nil,
            let defaultBalance = wallet?.balances.first {
            self.userDefaultsWrapper.storeValue(value: defaultBalance.token.id, forKey: .primaryBalance)
        }
    }
}
