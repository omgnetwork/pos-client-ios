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
        let transaction = StubGenerator.transactions().first!
        let vm = TransactionCellViewModel(transaction: transaction, currentUserAddress: "x")
        sut!.transactionCellViewModel = vm
        XCTAssertEqual(sut!.nameLabel.text, "Starbucks - CDC")
        XCTAssertEqual(sut!.timestampLabel.text, transaction.createdAt.toString(withFormat: "MMM dd, HH:mm"))
        XCTAssertEqual(sut!.amountLabel.text, "+ 10 TK1")
        XCTAssertEqual(sut!.amountLabel.textColor, Color.transactionCreditGreen.uiColor())
        XCTAssertEqual(sut!.statusTextLabel.text, "Success")
    }
}
