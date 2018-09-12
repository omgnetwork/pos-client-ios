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
    var viewModel: TestBalanceNavigationViewModel!

    override func setUp() {
        super.setUp()
        self.viewModel = TestBalanceNavigationViewModel()
        self.sut = BalanceNavigationViewController.initWithViewModel(self.viewModel)
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        self.sut = nil
        self.viewModel = nil
    }

    func testSingleBalanceDisplaysBalanceDetailVC() {
        self.viewModel.displayStyle = .single
        self.viewModel.onDisplayStyleUpdate?()
        XCTAssertTrue(self.sut.viewControllers[0].isKind(of: BalanceDetailViewController.self))
    }

    func testListBalanceDisplaysBalanceListVC() {
        self.viewModel.displayStyle = .list
        self.viewModel.onDisplayStyleUpdate?()
        XCTAssertTrue(self.sut.viewControllers[0].isKind(of: BalanceListViewController.self))
    }

    func testViewWillAppearCallsUpdateBalances() {
        self.viewModel.isUpdateBalancesCalled = false
        self.sut.viewWillAppear(false)
        XCTAssertTrue(self.viewModel.isUpdateBalancesCalled)
    }
}
