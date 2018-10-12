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
    let title: String = "qr_viewer.label.your_qr".localized()
    let hint: String = "qr_viewer.label.hint".localized()

    var onQRImageGenerate: ObjectClosure<UIImage?>?
    var onFailure: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    private var isLoading: Bool = false

    init(sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
        super.init()
    }

    func generateImage(withWidth width: CGFloat) {
        self.isLoading = true
        let tokenId = self.sessionManager.wallet!.balances.first!.token.id
        TransactionRequestBuilder(sessionManager: self.sessionManager,
                                  tokenId: tokenId).build(onSuccess: { [weak self] encodedString in
            let image = QRGenerator.generateQRCode(fromData: encodedString, outputSize: CGSize(width: width, height: width))
            self?.onQRImageGenerate?(image)
            self?.isLoading = false
        }, onFailure: { [weak self] error in
            self?.onFailure?(error)
            self?.isLoading = false
        })
    }
}
