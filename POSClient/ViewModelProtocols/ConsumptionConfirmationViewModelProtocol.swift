//
//  ConsumptionConfirmationViewModelProtocol.swift
//  POSClient
//
//  Created by Mederic Petit on 16/10/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

protocol ConsumptionConfirmationViewModelProtocol {
    var onSuccessApprove: SuccessClosure? { get set }
    var onFailApprove: FailureClosure? { get set }
    var onSuccessReject: SuccessClosure? { get set }
    var onFailReject: FailureClosure? { get set }
    var onLoadStateChange: ObjectClosure<Bool>? { get set }

    var title: String { get }
    var direction: String { get }
    var amountDisplay: String { get }
    var confirmButtonTitle: String { get }
    var rejectButtonTitle: String { get }
    var accountName: String { get }

    func approve()
    func reject()
}
