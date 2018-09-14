//
//  TestBalanceNavigationViewModel.swift
//  POSClientTests
//
//  Created by Mederic Petit on 12/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient

class TestBalanceNavigationViewModel: BalanceNavigationViewModelProtocol {
    var onDisplayStyleUpdate: EmptyClosure?
    var displayStyle: DisplayStyle = .list

    func stopObserving() {
        self.isStopObservingCalled = true
    }

    func updateBalances() {
        self.isUpdateBalancesCalled = true
    }

    var isStopObservingCalled = false
    var isUpdateBalancesCalled = false
}
