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
    case transactionRequestsQRString = "com.omisego.pos-client.transaction_requests_qr_string"
}

enum KeychainKey: String {
    case authenticationToken = "com.omisego.pos-client.authentication_token"
    case password = "com.omisego.pos-client.password"
}

struct Constant {
    static let urlScheme = "pos-client://"
    // LOCAL
//    static let baseURL = "http://192.168.1.42:4000"
//    static let APIKey = "dRrUkVp4WPypzHWJmEl6faJrBtvMZKY-27C63U6kAko"

    static let baseURL = "https://coffeego.omisego.io"
    static let APIKey = "fxqhJomqeemaAomNyfH_RphsVx4D2Z0ruBo_g-3jCY4"

    // Pagination
    static let perPage = 20
}

extension Notification.Name {
    static let didTapPayOrTopup = Notification.Name("didTapPayOrTopup")
    static let onConsumptionRequest = Notification.Name("onConsumptionRequest")
    static let onConsumptionConfirmation = Notification.Name("onConsumptionConfirmation")
}
