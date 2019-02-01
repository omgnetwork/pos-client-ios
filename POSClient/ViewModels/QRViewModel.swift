//
//  QRViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 22/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
import UIKit

class QRViewModel: BaseViewModel, QRViewModelProtocol {
    private let sessionManager: SessionManagerProtocol
    private let transactionRequestBuilder: TransactionRequestBuilderProtocol
    let title: String = "qr_viewer.label.your_qr".localized()
    let hint: String = "qr_viewer.label.hint".localized()

    var onTransactionRequestGenerated: EmptyClosure?
    var onTransactionRequestScanned: ObjectClosure<TransactionRequest>?
    var onFailure: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    private var isLoading: Bool = false {
        didSet {
            self.onLoadStateChange?(isLoading)
        }
    }

    private var observer: NSObjectProtocol?
    private var encodedQRCodeData: Data? {
        didSet {
            self.onTransactionRequestGenerated?()
        }
    }

    init(sessionManager: SessionManagerProtocol = SessionManager.shared,
         transactionRequestBuilder: TransactionRequestBuilderProtocol) {
        self.sessionManager = sessionManager
        self.transactionRequestBuilder = transactionRequestBuilder
        super.init()
        self.addObserver()
    }

    func buildTransactionRequests() {
        self.isLoading = true
        guard let tokenId = PrimaryTokenManager().getPrimaryTokenId() else {
            self.isLoading = false
            self.onFailure?(.unexpected)
            return
        }
        self.encodedQRCodeData = nil
        self.transactionRequestBuilder.build(withTokenId: tokenId, onSuccess: { [weak self] encodedString in
            self?.encodedQRCodeData = encodedString
            self?.isLoading = false
        }, onFailure: { [weak self] error in
            self?.onFailure?(error)
            self?.isLoading = false
        })
    }

    func qrImage(withWidth width: CGFloat) -> UIImage? {
        guard let data = self.encodedQRCodeData else { return nil }
        return QRGenerator.generateQRCode(fromData: data,
                                          outputSize: CGSize(width: width, height: width))
    }

    func prepareScanner() -> QRScannerViewController? {
        let verifier = QRClientVerifier(client: SessionManager.shared.httpClient)
        return QRScannerViewController(delegate: self, verifier: verifier, cancelButtonTitle: "global.cancel".localized())
    }

    deinit {
        if let observer = self.observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func addObserver() {
        self.observer = NotificationCenter.default.addObserver(forName: .onPrimaryTokenUpdate,
                                                               object: nil,
                                                               queue: nil) { [weak self] _ in
            self?.buildTransactionRequests()
        }
    }
}

extension QRViewModel: QRScannerViewControllerDelegate {
    func scannerDidCancel(scanner: QRScannerViewController) {
        scanner.dismiss(animated: true, completion: nil)
    }

    func scannerDidDecode(scanner: QRScannerViewController, transactionRequest: TransactionRequest) {
        guard let amount = transactionRequest.amount, amount > 0 else {
            self.onFailure?(POSClientError.message(message: "qr_viewer.error.invalid_request_amount".localized()))
            return
        }
        scanner.dismiss(animated: true, completion: nil)
        self.onTransactionRequestScanned?(transactionRequest)
    }

    func scannerDidFailToDecode(scanner _: QRScannerViewController, withError error: OMGError) {
        self.onFailure?(POSClientError.omiseGO(error: error))
    }
}
