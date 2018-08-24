//
//  MainTabBarViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 24/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {
    weak var observer: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.observer = NotificationCenter.default.addObserver(forName: Notification.Name.didTapPayOrTopup,
                                                               object: nil,
                                                               queue: nil) { [weak self] _ in
            self?.selectedIndex = 1
        }
        self.setTabBarItems()
    }

    func setTabBarItems() {
        if let item1 = self.viewControllers?[0].tabBarItem {
            item1.image = UIImage(named: "wallet_icon")
            item1.title = nil
            item1.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }

        if let item2 = self.viewControllers?[1].tabBarItem {
            item2.image = UIImage(named: "qr_icon")
            item2.title = ""
            item2.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }

        if let item3 = self.viewControllers?[2].tabBarItem {
            item3.image = UIImage(named: "profile_icon")
            item3.title = ""
            item3.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
    }

    deinit {
        if let observer = self.observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
