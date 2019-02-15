//
//  BalanceDetailViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 10/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient
import SBToaster
import XCTest

class BalanceDetailViewControllerTests: XCTestCase {
    var sut: BalanceDetailViewController!
    var viewModel: TestBalanceDetailViewModel!

    override func setUp() {
        super.setUp()
        self.viewModel = TestBalanceDetailViewModel()
        self.sut = BalanceDetailViewController.initWithViewModel(self.viewModel)
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        ToastCenter.default.cancelAll()
        self.viewModel = nil
        self.sut = nil
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.balanceLabel.text, "x")
        XCTAssertEqual(self.sut.tokenSymbolLabel.text, "x")
        XCTAssertEqual(self.sut.payButton.titleLabel?.attributedText, NSAttributedString(string: "x"))
        XCTAssertEqual(self.sut.lastUpdatedLabel.text, "x")
        XCTAssertEqual(self.sut.lastUpdatedValueLabel.text, "x")
        XCTAssertEqual(self.sut.navigationItem.title, "x")
    }

    func testOnDataUpdateTriggersDisplayUpdate() {
        XCTAssertEqual(self.sut.balanceLabel.text, "x")
        XCTAssertEqual(self.sut.tokenSymbolLabel.text, "x")
        XCTAssertEqual(self.sut.navigationItem.title, "x")
        self.viewModel.balanceDisplay = "y"
        self.viewModel.tokenSymbol = "y"
        self.viewModel.title = "y"
        self.viewModel.onDataUpdate?()
        XCTAssertEqual(self.sut.balanceLabel.text, "y")
        XCTAssertEqual(self.sut.tokenSymbolLabel.text, "y")
        XCTAssertEqual(self.sut.navigationItem.title, "y")
    }

    func testFailedGetWalletShowsError() {
        let error = POSClientError.unexpected
        self.viewModel.onFailGetWallet?(error)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, error.message)
    }

    func testLoadStateChangeTriggersLoading() {
        let e = self.expectation(description: "loading state change triggers loading view to show/hide")
        self.viewModel.onLoadStateChange?(true)
        XCTAssertEqual(self.sut.loading!.alpha, 1.0)
        self.viewModel.onLoadStateChange?(false)
        dispatchMain(afterMilliseconds: 10) {
            e.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(self.sut.loading!.alpha, 0)
    }

    func testTapPayOrTopupButtonPostNotification() {
        self.expectation(forNotification: .didTapPayOrTopup, object: nil)
        self.sut.tapPayOrTopupButton(self.sut.payButton)
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testTapRefreshIconCallsLoadData() {
        self.sut.tapRefreshIcon(NSObject())
        XCTAssertTrue(self.viewModel.isLoadDataCalled)
    }
}
