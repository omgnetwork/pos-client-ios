//
//  QRViewModelProtocol.swift
//  POSClient
//
//  Created by Mederic Petit on 12/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

protocol QRViewModelProtocol {
    var title: String { get }
    var hint: String { get }

    var onTransactionRequestGenerated: EmptyClosure? { get set }
    var onTransactionRequestScanned: ObjectClosure<TransactionRequest>? { get set }
    var onFailure: FailureClosure? { get set }
    var onLoadStateChange: ObjectClosure<Bool>? { get set }

    func buildTransactionRequests()
    func qrImage(withWidth width: CGFloat) -> UIImage?
    func prepareScanner() -> QRScannerViewController?
}
