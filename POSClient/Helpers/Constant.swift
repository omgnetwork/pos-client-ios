//
//  Constant.swift
//  POSClient
//
//  Created by Mederic Petit on 25/10/17.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import Foundation

enum UserDefaultKey: String {
    case email = "com.omisego.pos-client.email"
    case biometricEnabled = "com.omisego.pos-client.biometric_enabled"
}

enum KeychainKey: String {
    case authenticationToken = "com.omisego.pos-client.authentication_token"
    case password = "com.omisego.pos-client.password"
}

struct Constant {
    static let urlScheme = "pos-client://"
    // LOCAL
    static let baseURL = "https://coffeego.omisego.io"
    static let APIKey = "fxqhJomqeemaAomNyfH_RphsVx4D2Z0ruBo_g-3jCY4"

    // Pagination
    static let perPage = 20
}

extension Notification.Name {
    static let didTapPayOrTopup = Notification.Name("didTapPayOrTopup")
}
