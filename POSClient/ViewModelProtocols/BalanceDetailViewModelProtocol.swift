//
//  BalanceDetailViewModelProtocol.swift
//  POSClient
//
//  Created by Mederic Petit on 12/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

protocol BalanceDetailViewModelProtocol {
    var onFailGetWallet: FailureClosure? { get set }
    var onDataUpdate: SuccessClosure? { get set }
    var onLoadStateChange: ObjectClosure<Bool>? { get set }

    var balanceDisplay: String { get }
    var tokenSymbol: String { get }
    var title: String { get }
    var lastUpdatedString: String { get }
    var lastUpdated: String { get }
    var payOrTopupAttrStr: NSAttributedString { get }
    var balance: Balance? { get set }

    func loadData()
    func stopObserving()
}
