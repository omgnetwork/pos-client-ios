//
//  TransactionResultViewModelProtocol.swift
//  POSClient
//
//  Created by Mederic Petit on 31/1/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

protocol TransactionResultViewModelProtocol {
    var status: String { get }
    var amountDisplay: String { get }
    var direction: String { get }
    var accountName: String { get }
    var accountId: String { get }
    var error: String { get }
    var done: String { get }
    var statusImage: UIImage { get }
    var statusImageColor: UIColor { get }
}
