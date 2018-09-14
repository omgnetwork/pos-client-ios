//
//  QRViewControllerTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 10/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import XCTest

class QRViewControllerTests: XCTestCase {
    var sut: QRViewController!
    var viewModel: TestQRViewModel!

    override func setUp() {
        super.setUp()
        self.viewModel = TestQRViewModel()
        self.sut = QRViewController.initWithViewModel(self.viewModel)
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        self.sut = nil
        self.viewModel = nil
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.hintLabel.text, "x")
        XCTAssertEqual(self.sut.navigationItem.title, "x")
        XCTAssertNil(self.sut.qrImageView.image)
        XCTAssertEqual(self.viewModel.didCallQRImageWithWidth, CGFloat(self.sut.qrImageView.frame.width))
    }
}
