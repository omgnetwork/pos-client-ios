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
    var onPrimaryStateChange: EmptyClosure?

    var setPrimaryButtonTitle: String = "x"
    var isPrimary: Bool = false
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

    func setPrimary() {
        self.isSetPrimaryCalled = true
    }

    var isLoadDataCalled = false
    var isStopObservingCalled = false
    var isSetPrimaryCalled = false
}
