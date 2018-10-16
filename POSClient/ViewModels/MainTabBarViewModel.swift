//
//  MainTabBarViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 30/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class MainTabBarViewModel: BaseViewModel {
    var onTabSelected: ObjectClosure<Int>?
    var onConsumptionRequest: ObjectClosure<TransactionConsumption>?

    let item1Image = UIImage(named: "wallet_icon")
    let item1Title = "tab.balances.title".localized()
    let item2Image = UIImage(named: "qr_icon")
    let item2Title = "tab.qr.title".localized()
    let item3Image = UIImage(named: "profile_icon")
    let item3Title = "tab.profile.title".localized()

    private var observers: [NSObjectProtocol] = []

    override init() {
        super.init()
        let o1 = NotificationCenter.default.addObserver(forName: .didTapPayOrTopup,
                                                        object: nil,
                                                        queue: nil) { [weak self] _ in
            self?.onTabSelected?(1)
        }
        let o2 = NotificationCenter.default.addObserver(forName: .onConsumptionRequest,
                                                        object: nil,
                                                        queue: nil) { [weak self] in
            guard let consumption = $0.object as? TransactionConsumption else { return }
            self?.onConsumptionRequest?(consumption)
        }
        self.observers.append(contentsOf: [o1, o2])
    }

    deinit {
        self.observers.forEach({ NotificationCenter.default.removeObserver($0) })
    }
}
