//
//  TestQRViewModel.swift
//  POSClientTests
//
//  Created by Mederic Petit on 12/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import UIKit

class TestQRViewModel: QRViewModelProtocol {
    var title: String = "x"
    var hint: String = "x"

    var onTransactionRequestGenerated: EmptyClosure?
    var onFailure: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    func buildTransactionRequests() {
        self.didCallBuildTransactionRequests = true
    }

    func qrImage(withWidth width: CGFloat) -> UIImage? {
        self.didCallQRImageWithWidth = width
        return UIColor.red.image()
    }

    var didCallQRImageWithWidth: CGFloat?
    var didCallBuildTransactionRequests = false
}
