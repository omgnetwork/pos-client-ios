//
//  SocketListenerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 19/10/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import OmiseGO
@testable import POSClient
import XCTest

class SocketListenerTests: XCTestCase {
    var sut: SocketListener!
    var sessionManager: TestSessionManager!

    override func setUp() {
        super.setUp()
        self.sessionManager = TestSessionManager()
        self.sut = SocketListener(sessionManager: self.sessionManager)
    }

    override func tearDown() {
        super.tearDown()
        self.sessionManager = nil
        self.sut = nil
    }

    func testOnSetUserTriggersSocketConnectionAndListeningOnUserChannel() {
        let user = self.dummyUser()
        self.sessionManager.currentUser = user
        self.sut.onChange(event: .onUserUpdate(user: user))
        XCTAssertTrue(self.sessionManager.startscreamSocketClient.isConnected)
        XCTAssertNotNil(self.sessionManager.startscreamSocketClient.lastSentData)
        XCTAssertEqual("{\"data\":{},\"event\":\"phx_join\",\"ref\":\"1\",\"topic\":\"123\"}",
                       String(data: self.sessionManager.startscreamSocketClient.lastSentData!,
                              encoding: .utf8))
    }

    func testOnUnsetUserTriggersStopListeningOnUserChannel() {
        let user = self.dummyUser()
        self.sessionManager.currentUser = user
        self.sut.onChange(event: .onUserUpdate(user: user))
        self.sut.onChange(event: .onUserUpdate(user: nil))
        XCTAssertNotNil(self.sessionManager.startscreamSocketClient.lastSentData)
        XCTAssertEqual("{\"data\":{},\"event\":\"phx_leave\",\"ref\":\"2\",\"topic\":\"123\"}",
                       String(data: self.sessionManager.startscreamSocketClient.lastSentData!,
                              encoding: .utf8))
    }

    func testBroadcastNotificationOnConsumptionRequest() {
        let e = self.expectation(description: "broadcast notification on consumption request")
        let exptectedConsumption = self.dummyConsumption()
        var consumption: TransactionConsumption?
        let observer = NotificationCenter.default.addObserver(forName: .onConsumptionRequest, object: nil, queue: nil) { notification in
            consumption = notification.object as? TransactionConsumption
            e.fulfill()
        }
        let event = SocketEvent.transactionConsumptionRequest
        let object = WebsocketObject.transactionConsumption(object: exptectedConsumption)
        self.sut.on(object, error: nil, forEvent: event)
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(exptectedConsumption, consumption)
        NotificationCenter.default.removeObserver(observer)
    }

    func testBroadcastNotificationOnConsumptionFinalized() {
        let e = self.expectation(description: "broadcast notification on consumption finalized")
        let exptectedConsumption = self.dummyConsumption()
        var consumption: TransactionConsumption?
        let observer = NotificationCenter.default.addObserver(forName: .onConsumptionFinalized, object: nil, queue: nil) { notification in
            consumption = notification.object as? TransactionConsumption
            e.fulfill()
        }
        let event = SocketEvent.transactionConsumptionFinalized
        let object = WebsocketObject.transactionConsumption(object: exptectedConsumption)
        self.sut.on(object, error: nil, forEvent: event)
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(exptectedConsumption, consumption)
        NotificationCenter.default.removeObserver(observer)
    }

    private func dummyUser() -> User {
        return User(id: "123",
                    providerUserId: nil,
                    username: nil,
                    email: nil,
                    metadata: [:],
                    encryptedMetadata: [:],
                    socketTopic: "123",
                    createdAt: Date(),
                    updatedAt: Date())
    }

    private func dummyConsumption() -> TransactionConsumption {
        let token = Token(id: "123",
                          symbol: "1",
                          name: "1",
                          subUnitToUnit: 1,
                          metadata: [:],
                          encryptedMetadata: [:],
                          createdAt: Date(),
                          updatedAt: Date())
        let request = TransactionRequest(id: "123",
                                         type: .send,
                                         token: token,
                                         amount: nil,
                                         address: "1",
                                         user: nil,
                                         account: nil,
                                         correlationId: nil,
                                         status: .valid,
                                         socketTopic: "123",
                                         requireConfirmation: false,
                                         maxConsumptions: nil,
                                         consumptionLifetime: nil,
                                         expirationDate: nil,
                                         expirationReason: nil,
                                         createdAt: nil,
                                         expiredAt: nil,
                                         allowAmountOverride: true,
                                         maxConsumptionsPerUser: nil,
                                         formattedId: "123",
                                         exchangeAccountId: nil,
                                         exchangeWalletAddress: nil,
                                         exchangeAccount: nil,
                                         exchangeWallet: nil,
                                         metadata: [:],
                                         encryptedMetadata: [:])
        return TransactionConsumption(id: "123",
                                      status: .failed,
                                      amount: nil,
                                      estimatedRequestAmount: 1,
                                      estimatedConsumptionAmount: 1,
                                      finalizedRequestAmount: 1,
                                      finalizedConsumptionAmount: 1,
                                      token: token,
                                      correlationId: nil,
                                      idempotencyToken: "123",
                                      transaction: nil,
                                      address: "123",
                                      user: nil,
                                      account: nil,
                                      transactionRequest: request,
                                      socketTopic: "123",
                                      createdAt: Date(),
                                      expirationDate: nil,
                                      approvedAt: nil,
                                      rejectedAt: nil,
                                      confirmedAt: nil,
                                      failedAt: nil,
                                      expiredAt: nil,
                                      exchangeAccountId: nil,
                                      exchangeWalletAddress: nil,
                                      exchangeAccount: nil,
                                      exchangeWallet: nil,
                                      metadata: [:],
                                      encryptedMetadata: [:])
    }
}
