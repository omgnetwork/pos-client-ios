//
//  QRViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 22/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class QRViewModel: BaseViewModel, QRViewModelProtocol {
    private let sessionManager: SessionManagerProtocol
    let title: String = "qr_viewer.label.your_qr".localized()
    let hint: String = "qr_viewer.label.hint".localized()

    init(sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
        super.init()
    }

    func qrImage(withWidth width: CGFloat) -> UIImage? {
        guard let address = self.sessionManager.wallet?.address,
            let data = address.data(using: .isoLatin1) else {
            return nil
        }
        return QRGenerator.generateQRCode(fromData: data, outputSize: CGSize(width: width, height: width))
    }
}
