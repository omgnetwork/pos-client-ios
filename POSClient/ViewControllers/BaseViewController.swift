//
//  BaseViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 17/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import MBProgressHUD

class BaseViewController: UIViewController, Toastable, Loadable, Configurable {
    var loading: MBProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }

    func configureView() {
        self.configureViewModel()
    }

    func configureViewModel() {}
}

class BaseTableViewController: UITableViewController, Toastable, Loadable, Configurable {
    var loading: MBProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }

    func configureView() {
        self.configureViewModel()
    }

    func configureViewModel() {}
}
