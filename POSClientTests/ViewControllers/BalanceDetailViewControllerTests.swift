//
//  BalanceDetailViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 10/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient
import Toaster
import XCTest

class BalanceDetailViewControllerTests: XCTestCase {
    var sut: BalanceDetailViewController!

    override func setUp() {
        super.setUp()
        self.sut = Storyboard.balance.storyboard.instantiateViewController(withIdentifier: "BalanceDetailViewController") as! BalanceDetailViewController
        self.sut.viewModel.balance = StubGenerator.mainWallet().balances.first!
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        ToastCenter.default.cancelAll()
        self.sut = nil
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.balanceLabel.text, self.sut.viewModel.balanceDisplay)
        XCTAssertEqual(self.sut.tokenSymbolLabel.text, self.sut.viewModel.tokenSymbol)
        XCTAssertEqual(self.sut.payButton.titleLabel?.attributedText, self.sut.viewModel.payOrTopupAttrStr)
        XCTAssertEqual(self.sut.lastUpdatedLabel.text, self.sut.viewModel.lastUpdatedString)
        XCTAssertEqual(self.sut.lastUpdatedValueLabel.text, self.sut.viewModel.lastUpdated)
        XCTAssertEqual(self.sut.title, self.sut.viewModel.title)
    }

    func testOnDataUpdateTriggersDisplayUpdate() {
        XCTAssertEqual(self.sut.balanceLabel.text, "8\(Locale.current.groupingSeparator ?? ",")000")
        XCTAssertEqual(self.sut.tokenSymbolLabel.text, "BTC")
        XCTAssertEqual(self.sut.title, "Bitcoin")
        self.sut.viewModel.balance = StubGenerator.mainWallet().balances[1]
        self.sut.viewModel.onDataUpdate?()
        XCTAssertEqual(self.sut.balanceLabel.text, "33\(Locale.current.decimalSeparator ?? ".")33")
        XCTAssertEqual(self.sut.tokenSymbolLabel.text, "OMG")
        XCTAssertEqual(self.sut.title, "OmiseGO")
    }

    func testFailedGetWalletShowsError() {
        let error = POSClientError.unexpected
        self.sut.viewModel.onFailGetWallet?(error)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, error.message)
    }

    func testLoadStateChangeTriggersLoading() {
        let e = self.expectation(description: "loading state change triggers loading view to show/hide")
        self.sut.viewModel.onLoadStateChange?(true)
        XCTAssertEqual(self.sut.loading!.alpha, 1.0)
        self.sut.viewModel.onLoadStateChange?(false)
        dispatchMain(afterMilliseconds: 10) {
            e.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(self.sut.loading!.alpha, 0)
    }

    func testTapPayOrTopupButtonPostNotification() {
        var didReceiveNotification = false
        let e = self.expectation(description: "Receive a notification when tapping the button")
        let o = NotificationCenter.default.addObserver(forName: Notification.Name.didTapPayOrTopup, object: nil, queue: OperationQueue.main) { _ in
            didReceiveNotification = true
            e.fulfill()
        }
        self.sut.tapPayOrTopupButton(self.sut.payButton)
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(didReceiveNotification)
        NotificationCenter.default.removeObserver(o)
    }
}
