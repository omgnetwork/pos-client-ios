//
//  TestTransactionsViewModel.swift
//  POSClientTests
//
//  Created by Mederic Petit on 12/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit
@testable import POSClient

class TestTransactionsViewModel: TransactionsViewModelProtocol {
    var appendNewResultClosure: ObjectClosure<[IndexPath]>?
    var reloadTableViewClosure: EmptyClosure?
    var onFailLoadTransactions: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    var viewTitle: String = "x"

    func reloadTransactions() {
        self.isReloadTransactionCalled = true
    }

    func getNextTransactions() {
        self.isGetNextTransactionsCalled = true
    }

    func transactionCellViewModel(at indexPath: IndexPath) -> TransactionCellViewModel {
        self.isTransactionCellViewModelCalledWithIndexPath = indexPath
        return self.cellVM
    }

    func numberOfRow() -> Int {
        self.isNumberOfRowCalled = true
        return self.rowCount
    }

    func shouldLoadNext(atIndexPath indexPath: IndexPath) -> Bool {
        self.isShouldLoadNextCalledWithIndexPath = indexPath
        return false
    }

    var rowCount: Int = 0
    var cellVM = TransactionCellViewModel(transaction: StubGenerator.transactions().first!, currentUserAddress: "x")
    var isReloadTransactionCalled = false
    var isGetNextTransactionsCalled = false
    var isTransactionCellViewModelCalledWithIndexPath: IndexPath?
    var isNumberOfRowCalled = false
    var isShouldLoadNextCalledWithIndexPath: IndexPath?
}
