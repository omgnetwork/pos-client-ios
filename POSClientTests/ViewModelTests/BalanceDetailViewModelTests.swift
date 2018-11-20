//
//  BalanceDetailViewModelTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 4/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient
import XCTest

class BalanceDetailViewModelTests: XCTestCase {
    var sessionManager: TestSessionManager!
    var sut: BalanceDetailViewModel!

    override func setUp() {
        super.setUp()
        PrimaryTokenManager().clear()
        self.sessionManager = TestSessionManager(wallet: StubGenerator.mainWallet())
        self.sut = BalanceDetailViewModel(sessionManager: self.sessionManager,
                                          balance: self.sessionManager.wallet!.balances.first!)
    }

    override func tearDown() {
        self.sessionManager = nil
        self.sut = nil
        super.tearDown()
    }

    func testLoadBalancesCalled() {
        self.sut.loadData()
        XCTAssert(self.sessionManager.loadWalletCalled)
    }

    func testLoadBalancesFailed() {
        var didFail = false
        let error: OMGError = .unexpected(message: "Failed to load wallet")
        self.sut.onFailGetWallet = {
            XCTAssertEqual($0.message, error.message)
            didFail = true
        }
        self.sut.loadData()
        self.sessionManager.loadWalletFailed(withError: error)
        XCTAssert(didFail)
    }

    func testLoadBalances() {
        var didCallOnDataUpdate = false
        self.sut.onDataUpdate = {
            didCallOnDataUpdate = true
        }
        self.sut.loadData()
        self.sessionManager.loadWalletSuccess()
        XCTAssertTrue(didCallOnDataUpdate)
    }

    func testDataAreCorrect() {
        XCTAssertEqual(self.sut.balanceDisplay, "8,000")
        XCTAssertEqual(self.sut.tokenSymbol, "BTC")
    }

    func testPrimaryDataWhenIsPrimary() {
        self.sut.setPrimary()
        XCTAssertTrue(self.sut.isPrimary)
        XCTAssertEqual(self.sut.setPrimaryButtonTitle, "balance_detail.button.primary".localized())
    }

    func testPrimaryDataWhenIsNotPrimary() {
        XCTAssertFalse(self.sut.isPrimary)
        XCTAssertEqual(self.sut.setPrimaryButtonTitle, "balance_detail.button.set_primary".localized())
    }

    func testPrimaryDataWhenBalanceIsNil() {
        let sut = BalanceDetailViewModel(sessionManager: self.sessionManager)
        XCTAssertTrue(sut.isPrimary)
        XCTAssertEqual(sut.setPrimaryButtonTitle, "")
    }

    func testShowLoadingWhenFetching() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        XCTAssertFalse(loadingStatus)
        self.sut.loadData()
        XCTAssertTrue(loadingStatus)
        self.sessionManager.loadWalletSuccess()
        XCTAssertFalse(loadingStatus)
    }

    func testWalletUpdateTriggersProcess() {
        var onDataUpdateCalled = false
        self.sut.onDataUpdate = {
            onDataUpdateCalled = true
        }
        let wallet = StubGenerator.mainWallet()
        self.sessionManager.notify(event: .onWalletUpdate(wallet: wallet))
        XCTAssertTrue(onDataUpdateCalled)
    }

    func testWalletUpdateFailureTriggersFailureClosure() {
        var errorClosureCalled = false
        let error: OMGError = .unexpected(message: "Failed to load wallet")
        self.sut.onFailGetWallet = { walletError in
            XCTAssertEqual(walletError.message, error.message)
            errorClosureCalled = true
        }
        self.sessionManager.notify(event: .onWalletError(error: error))
        XCTAssertTrue(errorClosureCalled)
    }
}
