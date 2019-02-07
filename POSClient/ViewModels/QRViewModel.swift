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
    private let transactionRequestBuilder: TransactionRequestBuilderProtocol
    let title: String = "qr_viewer.label.your_qr".localized()
    let hint: String = "qr_viewer.label.hint".localized()

    var onTransactionRequestGenerated: EmptyClosure?
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

    init(transactionRequestBuilder: TransactionRequestBuilderProtocol) {
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
