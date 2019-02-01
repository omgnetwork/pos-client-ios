//
//  MainTabBarViewModelTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 5/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient
import XCTest

class MainTabBarViewModelTests: XCTestCase {
    var sut: MainTabBarViewModel!
    var sessionManager: TestSessionManager!

    override func setUp() {
        super.setUp()
        self.sessionManager = TestSessionManager(currentUser: StubGenerator.currentUser())
        self.sut = MainTabBarViewModel(sessionManager: self.sessionManager)
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testNotificationTriggersOnTabSelected() {
        var selectedIndex: Int?
        self.sut.onTabSelected = {
            selectedIndex = $0
        }
        NotificationCenter.default.post(name: Notification.Name.didTapPayOrTopup, object: nil)
        XCTAssertNotNil(selectedIndex)
        XCTAssertEqual(selectedIndex!, 1)
    }

    func testNotificationTriggersOnConsumptionRequest() {
        var consumption: TransactionConsumption?
        let expectedConsumption = StubGenerator.transactionConsumptionUserGenerated()
        self.sut.onConsumptionRequest = {
            consumption = $0
        }
        NotificationCenter.default.post(name: Notification.Name.onConsumptionRequest, object: expectedConsumption)
        XCTAssertNotNil(consumption)
        XCTAssertEqual(consumption, expectedConsumption)
    }

    func testNotificationTriggersOnConsumptionFinalizedForAUserRequest() {
        var stringData: (title: NSAttributedString, subtitle: NSAttributedString)?
        let consumption = StubGenerator.transactionConsumptionUserGenerated()
        self.sut.onConsumptionFinalized = {
            stringData = $0
        }
        NotificationCenter.default.post(name: Notification.Name.onConsumptionFinalized, object: consumption)
        XCTAssertEqual(stringData?.title.string, "Received 1 TK1")
        XCTAssertEqual(stringData?.subtitle.string, "From Headquarter")
    }

    func testNotificationTriggersOnConsumptionFinalizedForAnAccountRequest() {
        var stringData: (title: NSAttributedString, subtitle: NSAttributedString)?
        let consumption = StubGenerator.transactionConsumptionAccountGenerated()
        self.sut.onConsumptionFinalized = {
            stringData = $0
        }
        NotificationCenter.default.post(name: Notification.Name.onConsumptionFinalized, object: consumption)
        XCTAssertEqual(stringData?.title.string, "Sent 1 TK1")
        XCTAssertEqual(stringData?.subtitle.string, "To Headquarter")
    }
}
