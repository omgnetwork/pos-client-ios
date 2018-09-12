//
//  TestBalanceListViewModel.swift
//  POSClientTests
//
//  Created by Mederic Petit on 12/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient

class TestBalanceListViewModel: BalanceListViewModelProtocol {
    var onFailGetWallet: FailureClosure?
    var onTableDataChange: SuccessClosure?
    var onBalanceSelection: ObjectClosure<Balance>?

    var viewTitle: String = "x"

    func loadData() {
        self.isLoadDataCalled = true
    }

    func numberOfRow() -> Int {
        self.isNumberOfRowCalled = true
        return self.rowCount
    }

    func cellViewModel(forIndex _: Int) -> BalanceCellViewModel {
        self.isCellViewModelCalled = true
        return self.cellVM
    }

    func didSelectBalance(atIndex index: Int) {
        self.selectedBalanceIndex = index
    }

    var isLoadDataCalled = false
    var rowCount: Int = 0
    var isNumberOfRowCalled = false
    var cellVM: BalanceCellViewModel = BalanceCellViewModel(balance: StubGenerator.mainWalletSingleBalance().balances.first!)
    var isCellViewModelCalled = false
    var selectedBalanceIndex: Int?
}
