//
//  POSClientManager.swift
//  POSClient
//
//  Created by Mederic Petit on 17/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
import UIKit

class POSClientManager {
    static let shared: POSClientManager = POSClientManager()

    init() {
        Theme.apply()
    }
}
