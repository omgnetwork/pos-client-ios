//
//  MainTabBarViewModelTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 5/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import XCTest

class MainTabBarViewModelTests: XCTestCase {
    var sut: MainTabBarViewModel!

    override func setUp() {
        super.setUp()
        self.sut = MainTabBarViewModel()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func testNotificationTriggersOnTabSelected() {
        var selectedIndex: Int?
        self.sut.onTabSelected = { index in
            selectedIndex = index
        }
        NotificationCenter.default.post(name: Notification.Name.didTapPayOrTopup, object: nil)
        XCTAssertNotNil(selectedIndex)
        XCTAssertEqual(selectedIndex!, 1)
    }
}
