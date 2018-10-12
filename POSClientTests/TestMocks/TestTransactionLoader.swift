//
//  TestTransactionLoader.swift
//  POSClientTests
//
//  Created by Mederic Petit on 5/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import OmiseGO
@testable import POSClient

class TestTransactionLoader {
    var isListCalled = false

    var transactions: [Transaction]?
    var pagination: Pagination?
    var completionClosure: Transaction.PaginatedListRequestCallback!

    func loadTransactionSuccess() {
        self.completionClosure(
            OmiseGO.Response.success(
                data: JSONPaginatedListResponse<Transaction>(data: self.transactions!, pagination: self.pagination!)
            )
        )
    }

    func loadTransactionFailed(withError error: OMGError) {
        self.completionClosure(OmiseGO.Response.fail(error: error))
    }
}

extension TestTransactionLoader: TransactionLoaderProtocol {
    func list(withParams _: TransactionListParams,
              callback: @escaping Transaction.PaginatedListRequestCallback)
        -> Transaction.PaginatedListRequest? {
        self.isListCalled = true
        self.completionClosure = callback
        return nil
    }
}
