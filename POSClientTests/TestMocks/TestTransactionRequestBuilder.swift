//
//  TestTransactionRequestBuilder.swift
//  POSClientTests
//
//  Created by Mederic Petit on 18/10/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import UIKit

class TestTransactionRequestBuilder {
    var didCallBuildWithTokenId: String?

    var successClosure: ObjectClosure<Data>?
    var failureClosure: FailureClosure?

    func buildSuccess(withData data: Data) {
        self.successClosure?(data)
    }

    func buildFailure(withError error: POSClientError) {
        self.failureClosure?(error)
    }
}

extension TestTransactionRequestBuilder: TransactionRequestBuilderProtocol {
    func build(withTokenId tokenId: String, onSuccess: @escaping ObjectClosure<Data>, onFailure: @escaping FailureClosure) {
        self.didCallBuildWithTokenId = tokenId
        self.successClosure = onSuccess
        self.failureClosure = onFailure
    }
}
