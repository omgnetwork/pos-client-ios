//
//  MainTabBarViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 11/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import NotificationBannerSwift
@testable import POSClient
import XCTest

class MainTabBarViewControllerTests: XCTestCase {
    var sut: MainTabBarViewController!

    override func setUp() {
        super.setUp()
        self.sut =
            Storyboard.tabBar.storyboard.instantiateViewController(withIdentifier: "MainTabBarViewController") as? MainTabBarViewController
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        self.sut = nil
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.viewControllers?[0].tabBarItem!.image, self.sut.viewModel.item1Image)
        XCTAssertEqual(self.sut.viewControllers?[0].tabBarItem!.title, self.sut.viewModel.item1Title)
        XCTAssertEqual(self.sut.viewControllers?[1].tabBarItem!.image, self.sut.viewModel.item2Image)
        XCTAssertEqual(self.sut.viewControllers?[1].tabBarItem!.title, self.sut.viewModel.item2Title)
        XCTAssertEqual(self.sut.viewControllers?[2].tabBarItem!.image, self.sut.viewModel.item3Image)
        XCTAssertEqual(self.sut.viewControllers?[2].tabBarItem!.title, self.sut.viewModel.item3Title)
    }

    func testOnTabSelectedSelectTheCorrectTab() {
        self.sut.viewModel.onTabSelected?(2)
        XCTAssertEqual(self.sut.selectedIndex, 2)
    }

    func testOnConsumptionFinalizedShowsBanner() {
        let title = NSAttributedString(string: "x")
        let sub = NSAttributedString(string: "x")
        self.sut.viewModel.onConsumptionFinalized?((title: title, subtitle: sub))
        XCTAssertEqual(NotificationBannerQueue.default.numberOfBanners, 1)
    }

    func testShowTransactionHistory() {
        self.sut.showTransactionHistory()
        XCTAssertEqual(self.sut.selectedIndex, 2)
        XCTAssertEqual((self.sut.viewControllers![2] as! UINavigationController).viewControllers.count, 2)
        XCTAssertTrue((self.sut.viewControllers![2] as! UINavigationController).viewControllers[1].isKind(of: TransactionsViewController.self))
    }
}
