//
//  AppEvent.swift
//  POSClient
//
//  Created by Mederic Petit on 21/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

enum AppEvent {
    case onWalletUpdate(wallet: Wallet?)
    case onWalletError(error: OMGError)
    case onUserUpdate(user: User?)
    case onUserError(error: OMGError)
    case onAppStateUpdate(state: AppState)
    case onBioStateUpdate(enabled: Bool)
}
