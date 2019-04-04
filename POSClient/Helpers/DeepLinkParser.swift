//
//  DeepLinkParser.swift
//  POSClient
//
//  Created by Mederic Petit on 22/2/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import Foundation

class DeeplinkParser {
    static let shared = DeeplinkParser()
    private init() {}

    func parseDeepLink(_ url: URL) -> Deeplink? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true), let host = components.host else {
            return nil
        }

        var pathComponents = components.path.components(separatedBy: "/")
        pathComponents.removeFirst()

        switch (host, pathComponents.first) {
        case (_, .none): return nil
        case ("signup", .some("success")): return Deeplink.signupSuccess
        case ("resetPassword", .some("request")):
            guard let emailQI = components.queryItems?.filter({ $0.name == "email" }).first,
                let tokenQI = components.queryItems?.filter({ $0.name == "token" }).first,
                let email = emailQI.value,
                let token = tokenQI.value else {
                return nil
            }
            return Deeplink.requestPasswordReset(email: email, token: token)
        default: return nil
        }
    }
}
