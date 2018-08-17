//
//  AppDelegate.swift
//  POSClient
//
//  Created by Mederic Petit on 15/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication,
                     didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        _ = POSClientManager.shared
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.black
        self.window?.makeKeyAndVisible()
        self.loadRootView()
        return true
    }

    func loadRootView() {
        switch SessionManager.shared.state {
        case .logout:
            self.window?.rootViewController = Storyboard.login.storyboard.instantiateInitialViewController()
        case .loading:
            self.window?.rootViewController = Storyboard.loading.storyboard.instantiateInitialViewController()
        case .login:
            print("WARNING: TO UPDATE")
            self.window?.rootViewController = Storyboard.main.storyboard.instantiateInitialViewController()
        }
    }
}
