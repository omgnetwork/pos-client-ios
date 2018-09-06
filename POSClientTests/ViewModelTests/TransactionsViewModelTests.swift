//
//  TransactionsViewModelTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 5/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient
import XCTest

class TransactionsViewModelTests: XCTestCase {
    var sessionManager: TestSessionManager!
    var transactionLoader: TestTransactionLoader!
    var sut: TransactionsViewModel!

    override func setUp() {
        super.setUp()
        self.sessionManager = TestSessionManager(wallet: StubGenerator.mainWallet())
        self.transactionLoader = TestTransactionLoader()
        self.sut = TransactionsViewModel(transactionLoader: self.transactionLoader, sessionManager: self.sessionManager)
    }

    override func tearDown() {
        self.sessionManager = nil
        self.transactionLoader = nil
        self.sut = nil
        super.tearDown()
    }

    func testReloadTransactions() {
        self.sut.reloadTransactions()
        XCTAssert(self.transactionLoader.isListCalled)
    }

    func testGetNextTransactionsCalled() {
        self.sut.getNextTransactions()
        XCTAssert(self.transactionLoader.isListCalled)
    }

    func testLoadTransactionsFailed() {
        var didFail = false
        let error: OMGError = .unexpected(message: "Failed to load transactions")
        self.sut.onFailLoadTransactions = {
            XCTAssertEqual($0.message, error.message)
            didFail = true
        }
        self.transactionLoader.transactions = StubGenerator.transactions()
        self.transactionLoader.pagination = StubGenerator.pagination()
        self.sut.getNextTransactions()
        self.transactionLoader.loadTransactionFailed(withError: error)
        XCTAssert(didFail)
    }

    func testLoadTransactionsSuccess() {
        var appendNewResultClosureCalled = false
        var loadedIndexPath: [IndexPath] = []
        self.sut.appendNewResultClosure = { indexPaths in
            appendNewResultClosureCalled = true
            loadedIndexPath = indexPaths
        }
        self.goToLoadTransactionsFinished()
        XCTAssertTrue(appendNewResultClosureCalled)
        XCTAssertEqual(loadedIndexPath.count, self.transactionLoader.transactions!.count)
    }

    func testCallReloadTableViewClosureWhenViewModelsArrayIsEmpty() {
        var reloadTableViewClosureCalled = false
        self.sut.reloadTableViewClosure = {
            reloadTableViewClosureCalled = true
        }
        self.sut.reloadTransactions()
        XCTAssertTrue(reloadTableViewClosureCalled)
    }

    func testLoadingWhenRequesting() {
        var loadingStatus = false
        self.sut.onLoadStateChange = { loadingStatus = $0 }
        self.transactionLoader.transactions = StubGenerator.transactions()
        self.transactionLoader.pagination = StubGenerator.pagination()
        self.sut.getNextTransactions()
        XCTAssertTrue(loadingStatus)
        self.transactionLoader.loadTransactionSuccess()
        XCTAssertFalse(loadingStatus)
    }

    func testGetCellViewModel() {
        self.goToLoadTransactionsFinished()
        XCTAssert(self.sut.numberOfRow() == self.transactionLoader.transactions!.count)
        let indexPath = IndexPath(row: 0, section: 0)
        let cellViewModel = self.sut.transactionCellViewModel(at: indexPath)
        XCTAssertEqual(cellViewModel.name, self.transactionLoader.transactions!.first!.from.account!.name)
    }

    func testCellViewModel() {
        let transactionCredit = StubGenerator.transactions()[0]
        let cellViewModelCredit = TransactionCellViewModel(transaction: transactionCredit, currentUserAddress: "XXX123")
        XCTAssertEqual(cellViewModelCredit.name, "Starbucks - CDC")
        XCTAssertEqual(cellViewModelCredit.amount, "+ 10 TK1")
        XCTAssertEqual(cellViewModelCredit.color, Color.transactionCreditGreen.uiColor())
        XCTAssertEqual(cellViewModelCredit.statusText, "transactions.label.status.success".localized())
        let transactionDebit = StubGenerator.transactions()[1]
        let cellViewModelDebit = TransactionCellViewModel(transaction: transactionDebit, currentUserAddress: "XXX123")
        XCTAssertEqual(cellViewModelDebit.name, "Starbucks - CDC")
        XCTAssertEqual(cellViewModelDebit.amount, "- 10 TK1")
        XCTAssertEqual(cellViewModelDebit.color, Color.transactionDebitRed.uiColor())
        XCTAssertEqual(cellViewModelDebit.statusText, "transactions.label.status.success".localized())
    }
}

extension TransactionsViewModelTests {
    private func goToLoadTransactionsFinished() {
        self.transactionLoader.transactions = StubGenerator.transactions()
        self.transactionLoader.pagination = StubGenerator.pagination()
        self.sut.getNextTransactions()
        self.transactionLoader.loadTransactionSuccess()
    }
}
