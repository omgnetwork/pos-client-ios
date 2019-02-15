//
//  TransactionConfirmationViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 31/1/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class TransactionConfirmationViewModel: BaseViewModel, TransactionConfirmationViewModelProtocol {
    // Delegate closures
    var onSuccessGetTransactionRequest: SuccessClosure?
    var onFailGetTransactionRequest: FailureClosure?
    var onCompletedConsumption: ObjectClosure<TransactionBuilder>?
    var onPendingConsumptionConfirmation: EmptyClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    let title: String
    let direction: String
    let amountDisplay: String
    let confirm = "transaction_request_confirmation.button.confirm".localized()
    let cancel = "transaction_request_confirmation.button.cancel".localized()
    let accountName: String
    let accountId: String

    private var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    private var listenedConsumption: TransactionConsumption?

    private var transactionBuilder: TransactionBuilder
    private let sessionManager: SessionManagerProtocol
    private let transactionConsumptionGenerator: TransactionConsumptionGeneratorProtocol
    private let transactionConsumptionRejector: TransactionConsumptionRejectorProtocol

    required init(sessionManager: SessionManagerProtocol = SessionManager.shared,
                  transactionConsumptionGenerator: TransactionConsumptionGeneratorProtocol = TransactionConsumptionGenerator(),
                  transactionRequest: TransactionRequest,
                  transactionConsumptionRejector: TransactionConsumptionRejectorProtocol = TransactionConsumptionRejector()) {
        self.accountName = transactionRequest.account?.name ?? "-"
        self.accountId = transactionRequest.account?.id ?? "-"

        self.transactionBuilder = TransactionBuilder(transactionRequest: transactionRequest)

        self.sessionManager = sessionManager
        self.transactionConsumptionGenerator = transactionConsumptionGenerator
        self.transactionConsumptionRejector = transactionConsumptionRejector
        let formattedAmount = OMGNumberFormatter(precision: 5).string(from: transactionRequest.amount!,
                                                                      subunitToUnit: transactionRequest.token.subUnitToUnit)
        self.amountDisplay = "\(formattedAmount) \(transactionRequest.token.symbol)"
        switch transactionRequest.type {
        case .receive:
            self.title = "transaction_request_confirmation.send".localized()
            self.direction = "transaction_request_confirmation.to".localized()
        case .send:
            self.title = "transaction_request_confirmation.receive".localized()
            self.direction = "transaction_request_confirmation.from".localized()
        }
        super.init()
    }

    func consume() {
        self.isLoading = true
        let params = self.transactionBuilder.params(withidemPotencyToken: UUID().uuidString)
        self.transactionConsumptionGenerator.consume(withParams: params) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case let .success(data: consumption) where consumption.transactionRequest.requireConfirmation:
                self.listenedConsumption = consumption
                consumption.startListeningEvents(withClient: self.sessionManager.socketClient, eventDelegate: self)
                self.onPendingConsumptionConfirmation?()
            case let .success(data: consumption):
                self.transactionBuilder.transactionConsumption = consumption
                self.listenedConsumption = consumption
                self.onCompletedConsumption?(self.transactionBuilder)
            case let .fail(error: error):
                self.transactionBuilder.error = .omiseGO(error: error)
                self.onCompletedConsumption?(self.transactionBuilder)
            }
        }
    }

    func stopListening() {
        self.listenedConsumption?.stopListening(withClient: self.sessionManager.socketClient)
    }

    func waitingForUserConfirmationDidCancel() {
        self.isLoading = true
        self.transactionConsumptionRejector.reject(consumption: self.listenedConsumption) { [weak self] _ in
            self?.isLoading = false
        }
    }
}

extension TransactionConfirmationViewModel: TransactionConsumptionEventDelegate {
    func onSuccessfulTransactionConsumptionFinalized(_ transactionConsumption: TransactionConsumption) {
        self.transactionBuilder.transactionConsumption = transactionConsumption
        switch transactionConsumption.status {
        case .rejected:
            self.transactionBuilder.error =
                POSClientError.message(message: "transaction_request_confirmation.error.user_rejected".localized())
        default: break
        }
        self.onCompletedConsumption?(self.transactionBuilder)
    }

    func onFailedTransactionConsumptionFinalized(_ transactionConsumption: TransactionConsumption, error: APIError) {
        self.transactionBuilder.transactionConsumption = transactionConsumption
        self.transactionBuilder.error = .omiseGO(error: .api(apiError: error))
        self.onCompletedConsumption?(self.transactionBuilder)
    }

    func didStartListening() {
        print("Did start listening")
    }

    func didStopListening() {
        print("Did stop listening")
    }

    func onError(_ error: APIError) {
        print(error)
    }
}
