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
    @IBOutlet var openSettingsButton: UIButton!

    override func configureView() {
        super.configureView()
        self.hintLabel.text = "scanner_not_available.label.hint".localized()
        self.openSettingsButton.setTitle("scanner_not_available.button.open_settings".localized(), for: .normal)
        self.openSettingsButton.isHidden = self.settingsURL() == nil
    }

    @IBAction func tapOpenSettings(_: Any) {
        guard let settingsUrl = self.settingsURL() else { return }
        let optionsKeyDictionary = [UIApplication.OpenExternalURLOptionsKey(rawValue: "universalLinksOnly"): NSNumber(value: true)]

        UIApplication.shared.open(settingsUrl, options: optionsKeyDictionary, completionHandler: nil)
    }

    private func settingsURL() -> URL? {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) else {
            return nil
        }
        return settingsUrl
    }
}
