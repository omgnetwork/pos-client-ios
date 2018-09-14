//
//  QRViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 22/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class QRViewController: BaseViewController {
    @IBOutlet var hintLabel: UILabel!
    @IBOutlet var qrBorderView: UIView!
    @IBOutlet var qrImageView: UIImageView!

    var initialBrightness: CGFloat = UIScreen.main.brightness

    let viewModel = QRViewModel()

    override func configureView() {
        super.configureView()
        self.navigationItem.title = self.viewModel.title
        self.qrBorderView.addBorder(withColor: Color.greyBorder.uiColor(), width: 1, radius: 0)
        self.hintLabel.text = self.viewModel.hint
        self.view.layoutIfNeeded()
        self.qrImageView.image = self.viewModel.qrImage(withWidth: self.qrImageView.frame.width)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initialBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = 1
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIScreen.main.brightness = self.initialBrightness
    }
}
