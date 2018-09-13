//
//  TransactionTableViewCellTests.swift
//  POSClientTests
//
//  Created by Mederic Petit on 13/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient
import XCTest

class TransactionTableViewCellTests: XCTestCase {
    func testSetupsCorrectly() {
        let bundle = Bundle(for: TransactionTableViewCell.self)
        let sut = bundle.loadNibNamed("TransactionTableViewCell", owner: nil)?.first as? TransactionTableViewCell
        let vm = TransactionCellViewModel(transaction: StubGenerator.transactions().first!, currentUserAddress: "x")
        sut!.transactionCellViewModel = vm
        XCTAssertEqual(sut!.nameLabel.text, "Starbucks - CDC")
        XCTAssertEqual(sut!.timestampLabel.text, "Aug 23, 14:19")
        XCTAssertEqual(sut!.amountLabel.text, "+ 10 TK1")
        XCTAssertEqual(sut!.amountLabel.textColor, Color.transactionCreditGreen.uiColor())
        XCTAssertEqual(sut!.statusTextLabel.text, "Success")
    }
}
