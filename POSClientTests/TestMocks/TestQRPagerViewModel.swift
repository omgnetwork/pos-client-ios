//
//  TestQRPagerViewModel.swift
//  POSClientTests
//
//  Created by Mederic Petit on 7/2/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient

class TestQRPagerViewModel: QRPagerViewModelProtocol {
    var onCameraPermissionDeclined: SuccessClosure?
    var onTransactionRequestScanned: ObjectClosure<TransactionRequest>?
    var onFailure: FailureClosure?
    var onBarButtonNotificationToggle: SuccessClosure?
    var title: String = "x"

    var qrScannerViewController: QRScannerViewController?

    var didCallStartObserving = false
    var didCallStopObserving = false
    var didCallPrepareScanner = false

    func prepareScanner() -> QRScannerViewController? {
        self.didCallPrepareScanner = true
        return self.qrScannerViewController
    }

    func observerTabBarSelectNotification() {
        self.didCallStartObserving = true
    }

    func stopObserving() {
        self.didCallStopObserving = true
    }
}
