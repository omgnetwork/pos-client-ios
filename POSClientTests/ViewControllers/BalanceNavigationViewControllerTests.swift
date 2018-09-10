//
//  BalanceNavigationViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 10/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import XCTest

class BalanceNavigationViewControllerTests: XCTestCase {
    var sut: BalanceNavigationViewController!

    override func setUp() {
        super.setUp()
        self.sut = Storyboard.balance.storyboard.instantiateViewController(withIdentifier: "BalanceNavigationViewController")
            as! BalanceNavigationViewController
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        self.sut = nil
    }

    func testSingleBalanceDisplaysBalanceDetailVC() {
        self.sut.viewModel.displayStyle = .single
        XCTAssertTrue(self.sut.viewControllers[0].isKind(of: BalanceDetailViewController.self))
    }

    func testListBalanceDisplaysBalanceListVC() {
        self.sut.viewModel.displayStyle = .list
        XCTAssertTrue(self.sut.viewControllers[0].isKind(of: BalanceListViewController.self))
    }
}
