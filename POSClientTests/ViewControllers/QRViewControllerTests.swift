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

    override func setUp() {
        super.setUp()
        self.sut = Storyboard.qrCode.storyboard.instantiateViewController(withIdentifier: "QRViewController")
            as! QRViewController
        SessionManager.shared.wallet = StubGenerator.mainWallet()
        _ = self.sut.view
    }

    override func tearDown() {
        super.tearDown()
        self.sut = nil
    }

    func testSetupsCorrectly() {
        XCTAssertEqual(self.sut.hintLabel.text, self.sut.viewModel.hint)
        XCTAssertEqual(self.sut.navigationItem.title, self.sut.viewModel.title)
        XCTAssertNotNil(self.sut.qrImageView.image)
    }
}
