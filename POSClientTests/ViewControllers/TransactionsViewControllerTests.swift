//
//  TransactionsViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 11/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import Toaster
import XCTest

class TransactionsViewControllerTests: XCTestCase {
    var sut: TransactionsViewController!

    override func setUp() {
        super.setUp()
        self.sut = Storyboard.transaction.storyboard.instantiateViewController(withIdentifier: "TransactionsViewController") as! TransactionsViewController
        _ = UINavigationController(rootViewController: self.sut)
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        ToastCenter.default.cancelAll()
        self.sut = nil
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.title, self.sut.viewModel.viewTitle)
        XCTAssertEqual(self.sut.tableView.estimatedRowHeight, 62)
        XCTAssertEqual(self.sut.tableView.rowHeight, 62)
        XCTAssertEqual(self.sut.tableView.refreshControl, self.sut.refreshControl)
    }

    func testReloadTableViewClosureEndRefres() {
        self.sut.refreshControl!.beginRefreshing()
        XCTAssertTrue(self.sut.refreshControl!.isRefreshing)
        self.sut.viewModel.reloadTableViewClosure?()
        XCTAssertFalse(self.sut.refreshControl!.isRefreshing)
    }

    func testFailedLoadingShowsErrorAndEndRefresh() {
        self.sut.refreshControl!.beginRefreshing()
        XCTAssertTrue(self.sut.refreshControl!.isRefreshing)
        let error = POSClientError.unexpected
        self.sut.viewModel.onFailLoadTransactions?(error)
        XCTAssertEqual(ToastCenter.default.currentToast!.text, error.message)
        XCTAssertFalse(self.sut.refreshControl!.isRefreshing)
    }

    func testAppendNewResultClosureInsertsDataInTable() {
        // TODO: update after refactor
    }
}
