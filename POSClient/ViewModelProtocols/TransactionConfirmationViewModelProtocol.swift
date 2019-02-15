//
//  TransactionConfirmationViewModelProtocol.swift
//  POSClient
//
//  Created by Mederic Petit on 31/1/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

protocol TransactionConfirmationViewModelProtocol: WaitingForUserConfirmationViewControllerDelegate {
    var onLoadStateChange: ObjectClosure<Bool>? { get set }
    var onCompletedConsumption: ObjectClosure<TransactionBuilder>? { get set }
    var onPendingConsumptionConfirmation: EmptyClosure? { get set }

    var title: String { get }
    var direction: String { get }
    var amountDisplay: String { get }
    var confirm: String { get }
    var cancel: String { get }
    var accountName: String { get }
    var accountId: String { get }

    func consume()
    func stopListening()
}
