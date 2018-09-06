//
//  BaseViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 6/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import MBProgressHUD
@testable import POSClient
import Toaster
import XCTest

class BaseViewControllerTests: XCTestCase {
    var sut: BaseViewController!

    override func setUp() {
        super.setUp()
        self.sut = BaseViewController(nibName: nil, bundle: nil)
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        ToastCenter.default.cancelAll()
        self.sut = nil
    }

    func testShowLoading() {
        XCTAssertNil(self.sut.loading)
        self.sut.showLoading()
        XCTAssertNotNil(self.sut.loading)
    }

    func testHideLoading() {
        let e = self.expectation(description: "hideLoading should hide the view")
        self.sut.showLoading()
        XCTAssertEqual(self.sut.loading!.alpha, 1)
        self.sut.hideLoading()
        dispatchMain(afterMilliseconds: 10) {
            e.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(self.sut.loading!.alpha, 0)
    }

    func testShowMessage() {
        self.sut.showMessage("123")
        XCTAssertNotNil(ToastCenter.default.currentToast)
        XCTAssertEqual(ToastCenter.default.currentToast!.text!, "123")
    }

    func testShowError() {
        self.sut.showError(withMessage: "error")
        XCTAssertNotNil(ToastCenter.default.currentToast)
        XCTAssertEqual(ToastCenter.default.currentToast!.text!, "error")
    }
}

class BaseTableViewControllerTests: XCTestCase {
    var sut: BaseTableViewController!

    override func setUp() {
        super.setUp()
        self.sut = BaseTableViewController(nibName: nil, bundle: nil)
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        ToastCenter.default.cancelAll()
        self.sut = nil
    }

    func testShowLoading() {
        XCTAssertNil(self.sut.loading)
        self.sut.showLoading()
        XCTAssertNotNil(self.sut.loading)
    }

    func testHideLoading() {
        let e = self.expectation(description: "hideLoading should hide the view")
        self.sut.showLoading()
        XCTAssertEqual(self.sut.loading!.alpha, 1)
        self.sut.hideLoading()
        dispatchMain(afterMilliseconds: 10) {
            e.fulfill()
        }
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertEqual(self.sut.loading!.alpha, 0)
    }

    func testShowMessage() {
        self.sut.showMessage("123")
        XCTAssertNotNil(ToastCenter.default.currentToast)
        XCTAssertEqual(ToastCenter.default.currentToast!.text!, "123")
    }

    func testShowError() {
        self.sut.showError(withMessage: "error")
        XCTAssertNotNil(ToastCenter.default.currentToast)
        XCTAssertEqual(ToastCenter.default.currentToast!.text!, "error")
    }
}
