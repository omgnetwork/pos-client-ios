//
//  TestQRViewModel.swift
//  POSClientTests
//
//  Created by Mederic Petit on 12/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient

class TestQRViewModel: QRViewModelProtocol {
    var title: String = "x"
    var hint: String = "x"

    var onTransactionRequestGenerated: EmptyClosure?
    var onTransactionRequestScanned: ObjectClosure<TransactionRequest>?
    var onFailure: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?
    var qrScannerViewController: QRScannerViewController?

    func buildTransactionRequests() {
        self.didCallBuildTransactionRequests = true
    }

    func qrImage(withWidth width: CGFloat) -> UIImage? {
        self.didCallQRImageWithWidth = width
        return UIColor.red.image()
    }

    func prepareScanner() -> QRScannerViewController? {
        self.didCallPrepareScanner = true
        return self.qrScannerViewController
    }

    var didCallQRImageWithWidth: CGFloat?
    var didCallBuildTransactionRequests = false
    var didCallPrepareScanner = false
}
