//
//  BaseNavigationViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 24/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class BaseNavigationViewController: UINavigationController, Toastable {
    override func viewDidLoad() {
        super.viewDidLoad()

        let backImage = UIImage(named: "back_arrow")
        self.navigationBar.backIndicatorImage = backImage
        self.navigationBar.backIndicatorTransitionMaskImage = backImage
    }
}
