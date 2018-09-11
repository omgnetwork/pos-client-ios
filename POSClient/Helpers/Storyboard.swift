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
    case signup
    case balance
    case qrCode
    case profile
    case transaction
    case tabBar

    var name: String {
        switch self {
        case .loading: return "Loading"
        case .login: return "Login"
        case .signup: return "Signup"
        case .balance: return "Balance"
        case .qrCode: return "QRCode"
        case .profile: return "Profile"
        case .transaction: return "Transaction"
        case .tabBar: return "MainTabBar"
        }
    }

    var storyboard: UIStoryboard {
        return UIStoryboard(name: self.name, bundle: nil)
    }

    func viewControllerFromId<T: UIViewController>() -> T? {
        return self.storyboard.instantiateViewController(withIdentifier: String(describing: T.self)) as? T
    }
}
