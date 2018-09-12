//
//  BalanceNavigationViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 21/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

enum DisplayStyle {
    case single
    case list
}

class BalanceNavigationViewModel: BaseViewModel, BalanceNavigationViewModelProtocol {
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

    func stopObserving() {
        self.sessionManager.removeObserver(observer: self)
    }

    func updateBalances() {
        self.sessionManager.loadWallet()
    }

    private func process(wallet: Wallet?) {
        guard let wallet = wallet else { return }
        self.displayStyle = wallet.balances.count == 1 ? .single : .list
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
