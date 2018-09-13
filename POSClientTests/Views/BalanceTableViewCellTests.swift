//
//  BalanceTableViewCellTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 13/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import XCTest

class BalanceTableViewCellTests: XCTestCase {
    func testSetupsCorrectly() {
        let bundle = Bundle(for: BalanceTableViewCell.self)
        let sut = bundle.loadNibNamed("BalanceTableViewCell", owner: nil)?.first as? BalanceTableViewCell
        let vm = BalanceCellViewModel(balance: StubGenerator.mainWalletSingleBalance().balances.first!)
        sut?.balanceTableViewModel = vm
        XCTAssertEqual(sut?.tokenIconLabel.text, "BTC")
        XCTAssertEqual(sut?.tokenNameLabel.text, "Bitcoin")
        XCTAssertEqual(sut?.tokenSymbolLabel.text, "BTC")
        XCTAssertEqual(sut?.balanceLabel.text, "8\(Locale.current.groupingSeparator ?? ",")000")
    }
}
