//
//  MainTabBarViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 30/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class MainTabBarViewModel: BaseViewModel {
    var onTabSelected: ObjectClosure<Int>?

    let item1Image = UIImage(named: "wallet_icon")
    let item1Title = "tab.balances.title".localized()
    let item2Image = UIImage(named: "qr_icon")
    let item2Title = "tab.qr.title".localized()
    let item3Image = UIImage(named: "profile_icon")
    let item3Title = "tab.profile.title".localized()

    private weak var observer: NSObjectProtocol?

    override init() {
        super.init()
        self.observer = NotificationCenter.default.addObserver(forName: Notification.Name.didTapPayOrTopup,
                                                               object: nil,
                                                               queue: nil) { [weak self] _ in
            self?.onTabSelected?(1)
        }
    }

    deinit {
        if let observer = self.observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
