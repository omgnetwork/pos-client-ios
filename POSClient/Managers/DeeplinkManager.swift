//
//  DeeplinkManager.swift
//  POSClient
//
//  Created by Mederic Petit on 22/2/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import Foundation

enum Deeplink {
    case signupSuccess
}

class DeepLinkManager {
    static let shared = DeepLinkManager()

    private var link: Deeplink?
    private let navigator = DeeplinkNavigator()

    func handleDeeplink(url: URL) {
        self.link = DeeplinkParser.shared.parseDeepLink(url)
    }

    func checkDeepLink() {
        guard let link = link else {
            return
        }
        self.navigator.proceedToDeeplink(link)
        self.link = nil
    }
}
