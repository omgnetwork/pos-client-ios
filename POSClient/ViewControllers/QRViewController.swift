//
//  QRViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 22/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class QRViewController: BaseViewController {
    @IBOutlet var yourQRLabel: UILabel!
    @IBOutlet var hintLabel: UILabel!
    @IBOutlet var qrBorderView: UIView!
    @IBOutlet var qrImageView: UIImageView!
    @IBOutlet var doneButton: UIButton!

    let initialBrightness: CGFloat = UIScreen.main.brightness

    let viewModel = QRViewModel()

    override func configureView() {
        super.configureView()
        self.qrImageView.image = self.viewModel.qrImage(withWidth: self.qrImageView.frame.width)
        self.qrBorderView.addBorder(withColor: Color.greyBorder.uiColor(), width: 1, radius: 0)
        self.doneButton.addBorder(withColor: Color.omiseGOBlue.uiColor(), width: 1, radius: 4)
        self.yourQRLabel.text = self.viewModel.yourQR
        self.hintLabel.text = self.viewModel.hint
        self.doneButton.setTitle(self.viewModel.done, for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIScreen.main.brightness = 1
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIScreen.main.brightness = self.initialBrightness
    }

    @IBAction func tapDoneButton(_: Any) {
        self.viewModel.updateBalances()
        self.dismiss(animated: true, completion: nil)
    }
}
