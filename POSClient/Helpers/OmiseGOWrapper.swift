//
//  OmiseGOWrapper.swift
//  POSClient
//
//  Created by Mederic Petit on 20/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

protocol WalletLoaderProtocol {
    func getMain(withCallback callback: @escaping Wallet.RetrieveRequestCallback)
}

/// This wrapper has been created for the sake of testing with dependency injection
class WalletLoader: WalletLoaderProtocol {
    func getMain(withCallback callback: @escaping Wallet.RetrieveRequestCallback) {
        Wallet.getMain(using: SessionManager.shared.httpClient, callback: callback)
    }
}