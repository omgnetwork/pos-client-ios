//
//  ConsumptionConfirmationViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 16/10/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class ConsumptionConfirmationViewModel: BaseViewModel, ConsumptionConfirmationViewModelProtocol {
    // Delegate closures
    var onSuccessApprove: SuccessClosure?
    var onFailApprove: FailureClosure?
    var onSuccessReject: SuccessClosure?
    var onFailReject: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    let title: String
    let direction: String
    let amountDisplay: String
    let confirmButtonTitle = "consumption_confirmation.button.confirm".localized()
    let rejectButtonTitle = "consumption_confirmation.button.reject".localized()
    var accountName: String = "-"

    private var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(self.isLoading) }
    }

    private let consumption: TransactionConsumption
    private let transactionConsumptionApprover: TransactionConsumptionApproverProtocol

    required init(transactionConsumptionApprover: TransactionConsumptionApproverProtocol = TransactionConsumptionApprover(),
                  consumption: TransactionConsumption) {
        self.transactionConsumptionApprover = transactionConsumptionApprover
        self.title = "consumption_confirmation.send".localized()
        self.direction = "consumption_confirmation.to".localized()
        self.consumption = consumption
        self.accountName = consumption.account?.name ?? "-"
        let formattedAmount = OMGNumberFormatter().string(from: consumption.estimatedRequestAmount,
                                                          subunitToUnit: consumption.transactionRequest.token.subUnitToUnit)
        self.amountDisplay = "\(formattedAmount) \(consumption.transactionRequest.token.symbol)"
        super.init()
    }

    func approve() {
        self.isLoading = true
        self.transactionConsumptionApprover.approve(consumption: self.consumption) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.onSuccessApprove?()
            case let .failure(error):
                self?.onFailApprove?(.omiseGO(error: error))
            }
        }
    }

    func reject() {
        self.isLoading = true
        self.transactionConsumptionApprover.reject(consumption: self.consumption) { [weak self] result in
            self?.isLoading = false
            switch result {
            case .success:
                self?.onSuccessReject?()
            case let .failure(error):
                self?.onFailReject?(.omiseGO(error: error))
            }
        }
    }
}
