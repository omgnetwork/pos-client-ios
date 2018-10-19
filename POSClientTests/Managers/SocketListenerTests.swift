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
        let user = StubGenerator.currentUser()
        self.sessionManager.currentUser = user
        self.sut.onChange(event: .onUserUpdate(user: user))
        XCTAssertTrue(self.sessionManager.startscreamSocketClient.isConnected)
        XCTAssertNotNil(self.sessionManager.startscreamSocketClient.lastSentData)
        XCTAssertEqual("{\"data\":{},\"event\":\"phx_join\",\"ref\":\"1\",\"topic\":\"user:an_id\"}",
                       String(data: self.sessionManager.startscreamSocketClient.lastSentData!,
                              encoding: .utf8))
    }

    func testOnUnsetUserTriggersStopListeningOnUserChannel() {
        let user = StubGenerator.currentUser()
        self.sessionManager.currentUser = user
        self.sut.onChange(event: .onUserUpdate(user: user))
        self.sut.onChange(event: .onUserUpdate(user: nil))
        XCTAssertNotNil(self.sessionManager.startscreamSocketClient.lastSentData)
        XCTAssertEqual("{\"data\":{},\"event\":\"phx_leave\",\"ref\":\"2\",\"topic\":\"user:an_id\"}",
                       String(data: self.sessionManager.startscreamSocketClient.lastSentData!,
                              encoding: .utf8))
    }

    func testBroadcastNotificationOnConsumptionRequest() {
        let e = self.expectation(description: "broadcast notification on consumption request")
        let exptectedConsumption = StubGenerator.transactionConsumption()
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
        let exptectedConsumption = StubGenerator.transactionConsumption()
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
}
