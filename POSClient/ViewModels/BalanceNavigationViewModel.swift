//
//  BalanceNavigationViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 21/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class BalanceNavigationViewModel: BaseViewModel {
    enum DisplayStyle {
        case single
        case list
    }

    private let sessionManager: SessionManagerProtocol

    var onDisplayStyleUpdate: EmptyClosure?

    var displayStyle: DisplayStyle = .list {
        didSet {
            if oldValue != displayStyle {
                self.onDisplayStyleUpdate?()
            }
        }
    }

    init(sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
        super.init()
        self.process(wallet: sessionManager.wallet)
        sessionManager.attachObserver(observer: self)
    }

    func process(wallet: Wallet?) {
        guard let wallet = wallet else { return }
        self.displayStyle = wallet.balances.count == 1 ? .single : .list
    }

    func stopObserving() {
        self.sessionManager.removeObserver(observer: self)
    }
}

extension BalanceNavigationViewModel: Observer {
    func onChange(event: AppEvent) {
        switch event {
        case let .onWalletUpdate(wallet: wallet):
            self.process(wallet: wallet)
        default: break
        }
    }
}
