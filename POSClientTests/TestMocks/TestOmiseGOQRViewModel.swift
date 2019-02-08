//
//  TestOmiseGOQRViewModel.swift
//  POSClientTests
//
//  Created by Mederic Petit on 4/2/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import AVFoundation
@testable import OmiseGO

class TestOmiseGOQRViewModel: QRScannerViewModelProtocol {
    var didStartScanning: Bool = false
    var didStopScanning: Bool = false
    var didUpdateQRReaderPreviewLayer: Bool = false
    var didCallLoadTransactionRequestWithFormattedId: Bool = false

    var onLoadingStateChange: LoadingClosure?

    var onGetTransactionRequest: OnGetTransactionRequestClosure?

    var onError: OnErrorClosure?

    func startScanning(onStart _: (() -> Void)?) {
        self.didStartScanning = true
    }

    func stopScanning(onStop _: (() -> Void)?) {
        self.didStopScanning = true
    }

    func readerPreviewLayer() -> AVCaptureVideoPreviewLayer {
        return AVCaptureVideoPreviewLayer()
    }

    func updateQRReaderPreviewLayer(withFrame _: CGRect) {
        self.didUpdateQRReaderPreviewLayer = true
    }

    func isQRCodeAvailable() -> Bool {
        return true // for testing purpose we ignore the availabilty of the video device
    }

    func loadTransactionRequest(withFormattedId _: String) {
        self.didCallLoadTransactionRequestWithFormattedId = true
    }
}
