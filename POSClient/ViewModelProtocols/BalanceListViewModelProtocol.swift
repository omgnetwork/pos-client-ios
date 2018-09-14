//
//  BalanceListViewModelProtocol.swift
//  POSClient
//
//  Created by Mederic Petit on 12/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

protocol BalanceListViewModelProtocol {
    var onFailGetWallet: FailureClosure? { get set }
    var onTableDataChange: SuccessClosure? { get set }
    var onBalanceSelection: ObjectClosure<Balance>? { get set }
    var viewTitle: String { get }

    func loadData()
    func numberOfRow() -> Int
    func cellViewModel(forIndex index: Int) -> BalanceCellViewModel
    func didSelectBalance(atIndex index: Int)
}
