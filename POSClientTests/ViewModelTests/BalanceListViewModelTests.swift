//
//  BalanceListViewModelTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 4/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient
import XCTest

class BalanceListViewModelTests: XCTestCase {
    var sessionManager: TestSessionManager!
    var sut: BalanceListViewModel!

    override func setUp() {
        super.setUp()
        self.sessionManager = TestSessionManager()
        self.sut = BalanceListViewModel(sessionManager: self.sessionManager)
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
        var didCallOnTableDataChange = false
        self.sut.onTableDataChange = {
            didCallOnTableDataChange = true
        }
        self.sut.loadData()
        self.sessionManager.loadWalletSuccess()
        XCTAssertTrue(didCallOnTableDataChange)
    }

    func testGetCellViewModel() {
        self.sut.loadData()
        self.sessionManager.loadWalletSuccess()
        XCTAssertEqual(self.sut.numberOfRow(), self.sessionManager.wallet!.balances.count)
        let index = 0
        let cellViewModel = self.sut.cellViewModel(forIndex: index)
        XCTAssertEqual(cellViewModel.balance, self.sessionManager.wallet!.balances.first!)
    }

    func testCellViewModel() {
        let balance = StubGenerator.mainWallet().balances.first!
        let cellViewModel = BalanceCellViewModel(balance: balance)
        XCTAssertEqual(cellViewModel.balanceDisplay, "8,000")
        XCTAssertEqual(cellViewModel.tokenIcon, "BTC")
        XCTAssertEqual(cellViewModel.tokenName, "Bitcoin")
        XCTAssertEqual(cellViewModel.tokenSymbol, "BTC")
    }

    func testProcessGeneratesViewModelsCorrectly() {
        let wallet = StubGenerator.mainWallet()
        self.sut.process(wallet: wallet)
        XCTAssertEqual(wallet.balances.count, self.sut.numberOfRow())
        XCTAssertEqual(wallet.balances.first!, self.sut.cellViewModel(forIndex: 0).balance)
    }

    func testDidSelectBalanceCallsOnBalanceSelection() {
        var selectedBalance: Balance?
        self.sut.onBalanceSelection = { balance in
            selectedBalance = balance
        }
        self.sut.loadData()
        self.sessionManager.loadWalletSuccess()
        self.sut.didSelectBalance(atIndex: 0)
        XCTAssertEqual(selectedBalance, self.sessionManager.wallet!.balances.first!)
    }

    func testInitCallsProcessWalletsWithExistingData() {
        self.sessionManager.wallet = StubGenerator.mainWallet()
        let sut = BalanceListViewModel(sessionManager: sessionManager)

        XCTAssertEqual(sut.cellViewModel(forIndex: 0).balance, self.sessionManager.wallet!.balances.first!)
    }

    func testWalletUpdateTriggersProcess() {
        var onTableDataChangeCalled = false
        self.sut.onTableDataChange = {
            onTableDataChangeCalled = true
        }
        let wallet = StubGenerator.mainWallet()
        self.sessionManager.notify(event: .onWalletUpdate(wallet: wallet))
        XCTAssertTrue(onTableDataChangeCalled)
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
