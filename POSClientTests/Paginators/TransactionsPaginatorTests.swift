//
//  TransactionsPaginatorTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 6/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient
import XCTest

class TransactionsPaginatorTests: XCTestCase {
    func testLoadSuccess() {
        let loader = TestTransactionLoader()
        loader.transactions = StubGenerator.transactions()
        loader.pagination = StubGenerator.pagination()
        var didCallSuccess = false
        var loadedTransactions: [Transaction] = []
        let sut: TransactionPaginator = TransactionPaginator(transactionLoader: loader, successClosure: { transactions in
            didCallSuccess = true
            loadedTransactions = transactions
        }, failureClosure: { error in
            XCTFail(error.message)
        })
        sut.load()
        loader.loadTransactionSuccess()
        XCTAssertTrue(didCallSuccess)
        XCTAssertEqual(loadedTransactions, loader.transactions)
    }

    func testLoadFailure() {
        let loader = TestTransactionLoader()
        loader.transactions = StubGenerator.transactions()
        loader.pagination = StubGenerator.pagination()
        var didCallFail = false
        let error: OMGError = .unexpected(message: "error")
        var raisedError: POSClientError?
        let sut: TransactionPaginator = TransactionPaginator(transactionLoader: loader, successClosure: { _ in
            XCTFail("Call should succeed")
        }, failureClosure: { error in
            didCallFail = true
            raisedError = error
        })
        sut.load()
        loader.loadTransactionFailed(withError: error)
        XCTAssertTrue(didCallFail)
        XCTAssertEqual(raisedError?.message, error.message)
    }
}
