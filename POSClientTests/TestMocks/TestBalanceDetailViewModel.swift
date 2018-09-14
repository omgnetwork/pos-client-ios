//
//  TestBalanceDetailViewModel.swift
//  POSClientTests
//
//  Created by Mederic Petit on 12/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient

class TestBalanceDetailViewModel: BalanceDetailViewModelProtocol {
    var onFailGetWallet: FailureClosure?
    var onDataUpdate: SuccessClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    var balanceDisplay: String = "x"
    var tokenSymbol: String = "x"
    var title: String = "x"
    var lastUpdatedString: String = "x"
    var lastUpdated: String = "x"
    var payOrTopupAttrStr: NSAttributedString = NSAttributedString(string: "x")
    var balance: Balance? = StubGenerator.mainWallet().balances.first

    func loadData() {
        self.isLoadDataCalled = true
    }

    func stopObserving() {
        self.isStopObservingCalled = true
    }

    var isLoadDataCalled = false
    var isStopObservingCalled = false
}
