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
    var onFailure: FailureClosure?
    private let sessionManager: SessionManagerProtocol
    let title = "tab.qr.title".localized()

    init(sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
        super.init()
    }

    func prepareScanner() -> QRScannerViewController? {
        let verifier = QRClientVerifier(client: self.sessionManager.httpClient)
        return QRScannerViewController(delegate: self, verifier: verifier, cancelButtonTitle: "")
    }
}

extension QRPagerViewModel: QRScannerViewControllerDelegate {
    func scannerDidCancel(scanner _: QRScannerViewController) {}

    func scannerDidDecode(scanner: QRScannerViewController, transactionRequest: TransactionRequest) {
        guard let amount = transactionRequest.amount, amount > 0 else {
            self.onFailure?(POSClientError.message(message: "qr_viewer.error.invalid_request_amount".localized()))
            scanner.startCapture()
            return
        }
        self.onTransactionRequestScanned?(transactionRequest)
        scanner.startCapture()
    }

    func scannerDidFailToDecode(scanner _: QRScannerViewController, withError error: OMGError) {
        self.onFailure?(POSClientError.omiseGO(error: error))
    }
}
