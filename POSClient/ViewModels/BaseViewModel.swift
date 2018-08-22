//
//  BaseViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 17/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class BaseViewModel: NSObject {
    func handleOMGError(_ error: OMGError) {
        switch error {
        case let .api(apiError: apiError) where apiError.isAuthorizationError():
            SessionManager.shared.clearTokens()
        default: break
        }
    }
}
