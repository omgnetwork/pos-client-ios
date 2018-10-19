//
//  TransactionRequestBuilderTest.swift
//  POSClientTests
//
//  Created by Mederic Petit on 19/10/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import XCTest

class TransactionRequestBuilderTest: XCTestCase {
    var sut: TransactionRequestBuilder!
    var sessionManager: TestSessionManager!
    var transactionRequestCreator: TestTransactionRequestCreator!

    override func setUp() {
        super.setUp()
        UserDefaultsWrapper().clearValue(forKey: .transactionRequestsQRString)
        self.sessionManager = TestSessionManager(wallet: StubGenerator.mainWallet())
        self.transactionRequestCreator = TestTransactionRequestCreator()
        self.sut = TransactionRequestBuilder(sessionManager: self.sessionManager,
                                             transactionRequestCreator: self.transactionRequestCreator)
    }

    override func tearDown() {
        super.tearDown()
        self.sessionManager = nil
        self.sut = nil
    }

    func testDoesntRebuildIfStringAlreadyInUserDefaults() {
        let expectedData = "an_existing_string".data(using: .utf8)!
        UserDefaultsWrapper().storeData(data: expectedData, forKey: .transactionRequestsQRString)
        var data: Data?
        self.sut.build(withTokenId: "123", onSuccess: { d in
            data = d
        }, onFailure: { error in
            XCTFail(error.message)
        })
        XCTAssertEqual(expectedData, data)
    }

    func testBuildTheQRStringIfNotInUserDefault() {
        let e = self.expectation(description: "successfuly return an encoded string when create request succeed")
        let request1 = StubGenerator.transactionRequest()
        let request2 = StubGenerator.transactionRequest()
        let expectedData = "\(request1.formattedId)|\(request2.formattedId)".data(using: .utf8)
        var data: Data?
        self.sut.build(withTokenId: request1.token.id, onSuccess: { d in
            data = d
            e.fulfill()
        }, onFailure: { error in
            XCTFail(error.message)
            e.fulfill()
        })
        XCTAssertTrue(self.transactionRequestCreator.didCallCreate)
        self.transactionRequestCreator.createSuccess(withRequest: request1)
        self.transactionRequestCreator.createSuccess(withRequest: request2)
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(expectedData, data)
    }

    func testFailsToBuildTheQRStringIfNotInUserDefaultAndRequestFails() {
        let e = self.expectation(description: "fails to return an encoded string when create request fails")
        var error: POSClientError?
        self.sut.build(withTokenId: "123", onSuccess: { _ in
            XCTFail("Should not succeed")
            e.fulfill()
        }, onFailure: { err in
            error = err
            e.fulfill()
        })
        XCTAssertTrue(self.transactionRequestCreator.didCallCreate)
        self.transactionRequestCreator.createFailed(withError: .unexpected(message: "test"))
        self.transactionRequestCreator.createFailed(withError: .unexpected(message: "test"))
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(error?.message, "unexpected error: test")
    }
}
