//
//  TransactionBuilder.swift
//  POSClient
//
//  Created by Mederic Petit on 31/1/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import BigInt
import OmiseGO

struct TransactionBuilder {
    let transactionRequest: TransactionRequest
    var transactionConsumption: TransactionConsumption?
    var error: POSClientError?

    init(transactionRequest: TransactionRequest) {
        self.transactionRequest = transactionRequest
    }

    func params(withidemPotencyToken idemPotencyToken: String) -> TransactionConsumptionParams {
        return TransactionConsumptionParams(formattedTransactionRequestId: self.transactionRequest.formattedId,
                                            amount: nil,
                                            idempotencyToken: idemPotencyToken)
    }
}
