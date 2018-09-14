//
//  BalanceNavigationViewModelTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 4/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import OmiseGO
@testable import POSClient
import XCTest

class BalanceNavigationViewModelTests: XCTestCase {
    var sessionManager: TestSessionManager!
    var sut: BalanceNavigationViewModel!

    override func setUp() {
        super.setUp()
        self.sessionManager = TestSessionManager(wallet: StubGenerator.mainWallet())
        self.sut = BalanceNavigationViewModel(sessionManager: self.sessionManager)
    }

    override func tearDown() {
        self.sessionManager = nil
        self.sut = nil
        super.tearDown()
    }

    func testUpdateBalancesCallsLoadWallet() {
        self.sut.updateBalances()
        XCTAssertTrue(self.sessionManager.loadWalletCalled)
    }

    func testWalletUpdateDoesNotTriggersCallbackIfDisplayStyleIsTheSame() {
        XCTAssertEqual(self.sut.displayStyle, .list)
        var onDisplayStyleUpdateCalled = false
        self.sut.onDisplayStyleUpdate = {
            onDisplayStyleUpdateCalled = true
        }
        let wallet = StubGenerator.mainWallet()
        self.sessionManager.notify(event: .onWalletUpdate(wallet: wallet))
        XCTAssertFalse(onDisplayStyleUpdateCalled)
        XCTAssertEqual(self.sut.displayStyle, .list)
    }

    func testWalletUpdateTriggersCallbackIfDisplayStyleIsDifferent() {
        XCTAssertEqual(self.sut.displayStyle, .list)
        var onDisplayStyleUpdateCalled = false
        self.sut.onDisplayStyleUpdate = {
            onDisplayStyleUpdateCalled = true
        }
        let singleBalanceWallet = StubGenerator.mainWalletSingleBalance()
        self.sessionManager.notify(event: .onWalletUpdate(wallet: singleBalanceWallet))
        XCTAssertTrue(onDisplayStyleUpdateCalled)
        XCTAssertEqual(self.sut.displayStyle, .single)
    }
}
