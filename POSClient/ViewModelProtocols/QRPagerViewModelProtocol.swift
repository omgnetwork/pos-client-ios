//
//  QRPagerViewModelProtocol.swift
//  POSClient
//
//  Created by Mederic Petit on 5/2/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

protocol QRPagerViewModelProtocol {
    var onTransactionRequestScanned: ObjectClosure<TransactionRequest>? { get set }
    var onFailure: FailureClosure? { get set }
    var onBarButtonNotificationToggle: SuccessClosure? { get set }
    var title: String { get }

    func prepareScanner() -> QRScannerViewController?
    func observerTabBarSelectNotification()
    func stopObserving()
}
