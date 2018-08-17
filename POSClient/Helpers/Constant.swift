//
//  Constant.swift
//  POSClient
//
//  Created by Mederic Petit on 25/10/17.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

typealias ViewModelValidationClosure = ((_ errorMessage: String?) -> Void)
typealias EmptyClosure = () -> Void
typealias SuccessClosure = () -> Void
typealias ObjectClosure<T> = (_ object: T) -> Void
typealias FailureClosure = (_ error: POSClientError) -> Void

enum Storyboard {
    case loading
    case login
    case register
    case main // tmp

    var name: String {
        switch self {
        case .loading: return "Loading"
        case .login: return "Login"
        case .register: return "Register"
        case .main: return "Main"
        }
    }

    var storyboard: UIStoryboard {
        return UIStoryboard(name: self.name, bundle: nil)
    }
}

enum UserDefaultKeys: String {
    case userId = "token.user_id"
    case authenticationToken = "token.authentication_token"
}

enum AppState {
    case logout
    case loading
    case login
}

struct Constant {
    // LOCAL
    static let baseURL = "http://192.168.1.42:4000"
    static let baseSocketURL = "ws://192.168.1.42:4000"
    static let APIKey = "V6XMe4i4uRoQPO5cB8ox6zSzAdRa4_T8CDLb7gXdxvA"

    // Pagination
    static let perPage = 20
}
