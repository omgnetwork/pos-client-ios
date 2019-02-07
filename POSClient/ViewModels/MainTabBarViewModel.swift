//
//  MainTabBarViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 30/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import BigInt
import OmiseGO

class MainTabBarViewModel: BaseViewModel {
    var onTabSelected: ObjectClosure<Int>?
    var onConsumptionRequest: ObjectClosure<TransactionConsumption>?
    var onConsumptionFinalized: ObjectClosure<(title: NSAttributedString, subtitle: NSAttributedString)>?
    var onConsumptionRejected: EmptyClosure?

    let item1Image = UIImage(named: "wallet_icon")
    let item1Title = "tab.wallet.title".localized()
    let item2Image = UIImage(named: "qr_icon")
    let item2Title = "tab.qr.title".localized()
    let item3Image = UIImage(named: "profile_icon")
    let item3Title = "tab.profile.title".localized()

    private var observers: [NSObjectProtocol] = []
    private let sessionManager: SessionManagerProtocol

    init(sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
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
        let o3 = NotificationCenter.default.addObserver(forName: .onConsumptionFinalized,
                                                        object: nil,
                                                        queue: nil) { [weak self] in
            guard let consumption = $0.object as? TransactionConsumption else { return }
            self?.buildBanner(withConsumption: consumption)
        }
        self.observers.append(contentsOf: [o1, o2, o3])
    }

    func didSelect(item: UITabBarItem, inItems: [UITabBarItem]?) {
        if let items = inItems, items.count == 3, item == items[1] {
            NotificationCenter.default.post(name: .onTapQRTabBarButton, object: nil)
        }
    }

    private func buildBanner(withConsumption consumption: TransactionConsumption) {
        guard consumption.status == .confirmed else {
            self.onConsumptionRejected?()
            return
        }
        let type: String
        let direction: String
        let formattedAmount = OMGNumberFormatter().string(from: consumption.estimatedRequestAmount,
                                                          subunitToUnit: consumption.transactionRequest.token.subUnitToUnit)
        switch consumption.transactionRequest.type {
        case .receive where consumption.transactionRequest.user == self.sessionManager.currentUser,
             .send where consumption.transactionRequest.user != self.sessionManager.currentUser:
            type = "tab.notification.received".localized()
            direction = "tab.notification.from".localized()
        case .send where consumption.transactionRequest.user == self.sessionManager.currentUser,
             .receive where consumption.transactionRequest.user != self.sessionManager.currentUser:
            type = "tab.notification.sent".localized()
            direction = "tab.notification.to".localized()
        default:
            type = ""
            direction = ""
        }
        let title = "\(type) \(formattedAmount) \(consumption.transactionRequest.token.symbol)"
        let aTitle = NSAttributedString(string: title,
                                        attributes: [
                                            NSAttributedString.Key.font: Font.avenirMedium.withSize(17),
                                            NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        let target: String? = consumption.transactionRequest.user ==
            self.sessionManager.currentUser ?
            consumption.account?.name : consumption.transactionRequest.account?.name
        let subtitle = "\(direction) \(target ?? "-")"
        let aSubtitle = NSAttributedString(string: subtitle,
                                           attributes: [
                                               NSAttributedString.Key.font: Font.avenirMedium.withSize(14),
                                               NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        let message = (aTitle, aSubtitle)
        self.onConsumptionFinalized?(message)
    }

    deinit {
        self.observers.forEach({ NotificationCenter.default.removeObserver($0) })
    }
}
