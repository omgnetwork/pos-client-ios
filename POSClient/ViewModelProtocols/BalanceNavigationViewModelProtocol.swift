//
//  BalanceNavigationViewModelProtocol.swift
//  POSClient
//
//  Created by Mederic Petit on 12/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

protocol BalanceNavigationViewModelProtocol {
    var onDisplayStyleUpdate: EmptyClosure? { get set }
    var displayStyle: DisplayStyle { get set }

    func stopObserving()
    func updateBalances()
}
