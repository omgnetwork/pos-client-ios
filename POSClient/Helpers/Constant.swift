//
//  Constant.swift
//  POSClient
//
//  Created by Mederic Petit on 25/10/17.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import Foundation

enum UserDefaultKeys: String {
    case userId = "token.user_id"
    case authenticationToken = "token.authentication_token"
}

struct Constant {
    static let urlScheme = "pos-client://"
    // LOCAL
    static let baseURL = "http://192.168.1.42:4000"
    static let APIKey = "1i0I7MBjts7eKDxp3hQKlVpzSfA7nsIAeMDg-md_B-E"

    // Pagination
    static let perPage = 20
}

extension Notification.Name {
    static let didTapPayOrTopup = Notification.Name("didTapPayOrTopup")
}
