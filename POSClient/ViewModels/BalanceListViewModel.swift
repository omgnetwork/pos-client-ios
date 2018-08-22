//
//  BalanceListViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 20/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class BalanceListViewModel: BaseViewModel {
    // Delegate Closures
    var onFailGetWallet: FailureClosure?
    var onTableDataChange: SuccessClosure?
    var onBalanceSelection: ObjectClosure<Balance>?
    var onLoadStateChange: ObjectClosure<Bool>?

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    let viewTitle = "balance_list.view.title".localized()
    private var balanceCellViewModels: [BalanceCellViewModel] = []
    private let walletLoader: WalletLoaderProtocol

    init(walletLoader: WalletLoaderProtocol = WalletLoader()) {
        self.walletLoader = walletLoader
        super.init()
    }

    @objc func loadData() {
        self.isLoading = true
        self.walletLoader.getMain { result in
            self.isLoading = false
            switch result {
            case let .success(data: wallet):
                self.processWallet(wallet)
            case let .fail(error: error):
                self.handleOMGError(error)
                self.onFailGetWallet?(.omiseGO(error: error))
            }
        }
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

    private func processWallet(_ wallet: Wallet) {
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
