//
//  BalanceListViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 10/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import Toaster
import XCTest

class BalanceListViewControllerTests: XCTestCase {
    var sut: BalanceListViewController!

    override func setUp() {
        super.setUp()
        self.sut = Storyboard.balance.storyboard.instantiateViewController(withIdentifier: "BalanceListViewController") as! BalanceListViewController
        _ = UINavigationController(rootViewController: self.sut)
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        ToastCenter.default.cancelAll()
        self.sut = nil
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.tableView.estimatedRowHeight, 72)
        XCTAssertEqual(self.sut.tableView.refreshControl, self.sut.refreshControl)
    }

    func testOnTableDataChangeEndRefresh() {
        self.sut.refreshControl.beginRefreshing()
        XCTAssertTrue(self.sut.refreshControl.isRefreshing)
        self.sut.viewModel.onTableDataChange?()
        XCTAssertFalse(self.sut.refreshControl.isRefreshing)
    }

    func testFailedLoginShowsErrorAndEndRefresh() {
        self.sut.refreshControl.beginRefreshing()
        XCTAssertTrue(self.sut.refreshControl.isRefreshing)
        let error = POSClientError.unexpected
        self.sut.viewModel.onFailGetWallet?(error)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, error.message)
        XCTAssertFalse(self.sut.refreshControl.isRefreshing)
    }

    func testOnBalanceSelectionPushesBalanceDetailViewController() {
        let e = self.expectation(description: "onBalanceSelection pushes BalanceDetailViewController")
        XCTAssertEqual(self.sut.navigationController!.viewControllers.count, 1)
        let balance = StubGenerator.mainWallet().balances.first!
        dispatchMain {
            self.sut.viewModel.onBalanceSelection?(balance)
            e.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(self.sut.navigationController!.viewControllers.count, 2)
        guard let balanceDetailViewController: BalanceDetailViewController =
            self.sut.navigationController!.viewControllers[1] as? BalanceDetailViewController else {
            XCTFail("Unexpected view contrller type")
            return
        }
        XCTAssertEqual(balanceDetailViewController.viewModel.balance!, balance)
    }
}
