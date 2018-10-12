//
//  QRViewModelProtocol.swift
//  POSClient
//
//  Created by Mederic Petit on 12/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

protocol QRViewModelProtocol {
    var title: String { get }
    var hint: String { get }

    var onQRImageGenerate: ObjectClosure<UIImage?>? { get set }
    var onFailure: FailureClosure? { get set }
    var onLoadStateChange: ObjectClosure<Bool>? { get set }

    func generateImage(withWidth width: CGFloat)
}
