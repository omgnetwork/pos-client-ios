//
//  BalanceListViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 20/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class BalanceListViewModel: BaseViewModel, BalanceListViewModelProtocol {
    // Delegate Closures
    var onFailGetWallet: FailureClosure?
    var onTableDataChange: SuccessClosure?
    var onBalanceSelection: ObjectClosure<Balance>?

    let viewTitle = "balance_list.view.title".localized()
    private var balanceCellViewModels: [BalanceCellViewModel] = []
    private let sessionManager: SessionManagerProtocol

    init(sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
        super.init()
        sessionManager.attachObserver(observer: self)
        self.process(wallet: sessionManager.wallet)
    }

    @objc func loadData() {
        self.sessionManager.loadWallet()
    }

    func numberOfRow() -> Int {
        return self.balanceCellViewModels.count
    }

    func cellViewModel(forIndex index: Int) -> BalanceCellViewModel {
        return self.balanceCellViewModels[index]
    }

    func didSelectBalance(atIndex index: Int) {
        let balance = self.balanceCellViewModels[index].balance
        self.onBalanceSelection?(balance)
    }

    private func process(wallet: Wallet?) {
        guard let wallet = wallet else { return }
        self.generateTableViewModels(fromBalances: wallet.balances)
        self.onTableDataChange?()
    }

    private func generateTableViewModels(fromBalances balances: [Balance]) {
        var newViewModels: [BalanceCellViewModel] = []
        balances.forEach({
            let viewModel = BalanceCellViewModel(balance: $0)
            newViewModels.append(viewModel)
        })
        self.balanceCellViewModels = newViewModels
    }
}

extension BalanceListViewModel: Observer {
    func onChange(event: AppEvent) {
        switch event {
        case let .onWalletUpdate(wallet: wallet):
            self.process(wallet: wallet)
        case let .onWalletError(error: error):
            self.onFailGetWallet?(.omiseGO(error: error))
        default: break
        }
    }
}
