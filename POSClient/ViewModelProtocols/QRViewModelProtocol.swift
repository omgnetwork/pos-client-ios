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

    func qrImage(withWidth width: CGFloat) -> UIImage?
}
