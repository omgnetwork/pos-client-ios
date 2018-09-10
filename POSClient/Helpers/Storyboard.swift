//
//  Storyboard.swift
//  POSClient
//
//  Created by Mederic Petit on 20/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

enum Storyboard {
    case loading
    case login
    case register
    case balance
    case qrCode
    case tabBar

    var name: String {
        switch self {
        case .loading: return "Loading"
        case .login: return "Login"
        case .register: return "Register"
        case .balance: return "Balance"
        case .qrCode: return "QRCode"
        case .tabBar: return "MainTabBar"
        }
    }

    var storyboard: UIStoryboard {
        return UIStoryboard(name: self.name, bundle: nil)
    }
}
