//
//  ScannerNotAvailableViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 6/2/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class ScannerNotAvailableViewController: BaseViewController {
    @IBOutlet var hintLabel: UILabel!

    override func configureView() {
        super.configureView()
        self.hintLabel.text = "scanner_not_available.label.hint".localized()
    }
}
