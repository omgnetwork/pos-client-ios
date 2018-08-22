//
//  MainViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 17/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    @IBAction func tapLogout(_: Any) {
        SessionManager.shared.logout(withSuccessClosure: {
            (UIApplication.shared.delegate as? AppDelegate)?.loadRootView()
        }, failure: { error in
            print(error)
        })
    }
}
