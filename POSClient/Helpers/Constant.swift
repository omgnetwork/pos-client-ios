//
//  Constant.swift
//  POSClient
//
//  Created by Mederic Petit on 25/10/17.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

enum UserDefaultKeys: String {
    case userId = "token.user_id"
    case authenticationToken = "token.authentication_token"
}

struct Constant {
    // LOCAL
    static let baseURL = "http://192.168.82.11:4000"
    static let APIKey = "V6XMe4i4uRoQPO5cB8ox6zSzAdRa4_T8CDLb7gXdxvA"

    // Pagination
    static let perPage = 20
}
