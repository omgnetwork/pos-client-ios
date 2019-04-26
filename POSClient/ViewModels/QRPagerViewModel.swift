//
//  QRPagerViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 5/2/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class QRPagerViewModel: BaseViewModel, QRPagerViewModelProtocol {
    var onTransactionRequestScanned: ObjectClosure<TransactionRequest>?
    var onBarButtonNotificationToggle: SuccessClosure?
    var onCameraPermissionDeclined: SuccessClosure?
    var onFailure: FailureClosure?
    let title = "tab.qr.title".localized()
    private let sessionManager: SessionManagerProtocol
    private var observers: [NSObjectProtocol] = []

    init(sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
        super.init()
    }

    func observerTabBarSelectNotification() {
        let observer = NotificationCenter.default.addObserver(forName: .onTapQRTabBarButton,
                                                              object: nil,
                                                              queue: nil) { [weak self] _ in
            self?.onBarButtonNotificationToggle?()
        }
        self.observers = [observer]
    }

    func stopObserving() {
        self.observers.forEach { NotificationCenter.default.removeObserver($0) }
    }

    func prepareScanner() -> QRScannerViewController? {
        let verifier = QRClientVerifier(client: self.sessionManager.httpClient)
        return QRScannerViewController(delegate: self, verifier: verifier, cancelButtonTitle: "")
    }

    deinit {
        self.stopObserving()
    }
}

extension QRPagerViewModel: QRScannerViewControllerDelegate {
    func userDidChoosePermission(granted: Bool) {
        if !granted {
            self.onCameraPermissionDeclined?()
        }
    }

    func scannerDidCancel(scanner _: QRScannerViewController) {}

    func scannerDidDecode(scanner: QRScannerViewController, transactionRequest: TransactionRequest) {
        guard let amount = transactionRequest.amount, amount > 0 else {
            self.onFailure?(POSClientError.message(message: "qr_viewer.error.invalid_request_amount".localized()))
            scanner.startCapture()
            return
        }
        self.onTransactionRequestScanned?(transactionRequest)
    }

    func scannerDidFailToDecode(scanner _: QRScannerViewController, withError error: OMGError) {
        self.onFailure?(POSClientError.omiseGO(error: error))
    }
}
