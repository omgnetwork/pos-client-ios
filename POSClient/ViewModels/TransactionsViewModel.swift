//
//  TransactionsViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 24/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
import UIKit

class TransactionsViewModel: BaseViewModel {
    // Delegate closures
    var appendNewResultClosure: ObjectClosure<[IndexPath]>?
    var reloadTableViewClosure: EmptyClosure?
    var onFailLoadTransactions: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    let viewTitle: String = "transactions.view.title".localized()

    private var transactionCellViewModels: [TransactionCellViewModel]! = [] {
        didSet {
            if transactionCellViewModels.isEmpty { self.reloadTableViewClosure?() }
        }
    }

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(self.isLoading) }
    }

    var paginator: TransactionPaginator!
    private let sessionManager: SessionManagerProtocol

    init(transactionLoader: TransactionLoaderProtocol = TransactionLoader(),
         sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
        super.init()
        self.paginator = TransactionPaginator(transactionLoader: transactionLoader,
                                              successClosure: { [weak self] transactions in
                                                  self?.process(transactions)
                                                  self?.isLoading = false
                                              }, failureClosure: { [weak self] error in
                                                  self?.isLoading = false
                                                  self?.onFailLoadTransactions?(error)
        })
    }

    func reloadTransactions() {
        self.paginator.reset()
        self.transactionCellViewModels = []
        self.getNextTransactions()
    }

    func getNextTransactions() {
        self.isLoading = true
        self.paginator.loadNext()
    }

    private func process(_ transactions: [Transaction]) {
        guard let wallet = self.sessionManager.wallet else { return }
        var newCellViewModels: [TransactionCellViewModel] = []
        transactions.forEach({
            newCellViewModels.append(TransactionCellViewModel(transaction: $0,
                                                              currentUserAddress: wallet.address))
        })
        var indexPaths: [IndexPath] = []
        for row in
        self.transactionCellViewModels.count ..< (self.transactionCellViewModels.count + newCellViewModels.count) {
            indexPaths.append(IndexPath(row: row, section: 0))
        }
        self.transactionCellViewModels.append(contentsOf: newCellViewModels)
        self.appendNewResultClosure?(indexPaths)
    }
}

extension TransactionsViewModel {
    func transactionCellViewModel(at indexPath: IndexPath) -> TransactionCellViewModel {
        return self.transactionCellViewModels[indexPath.row]
    }

    func numberOfRow() -> Int {
        return self.transactionCellViewModels.count
    }

    func shouldLoadNext(atIndexPath indexPath: IndexPath) -> Bool {
        return self.numberOfRow() - indexPath.row < 5 && !self.paginator.reachedLastPage
    }
}
