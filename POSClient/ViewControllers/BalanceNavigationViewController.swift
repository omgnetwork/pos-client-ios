//
//  BalanceNavigationViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 21/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class BalanceNavigationViewController: UINavigationController {
    let viewModel: BalanceNavigationViewModel = BalanceNavigationViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.onDisplayStyleUpdate = { [weak self] in
            self?.setInitialViewController()
        }
    }

    required init?(coder aCoder: NSCoder) {
        super.init(coder: aCoder)
        self.setInitialViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.updateBalances()
    }

    private func setInitialViewController() {
        let viewController: UIViewController
        switch self.viewModel.displayStyle {
        case .single:
            viewController = Storyboard.balance.storyboard.instantiateViewController(withIdentifier: "BalanceDetailViewController")
        case .list:
            viewController = Storyboard.balance.storyboard.instantiateViewController(withIdentifier: "BalanceListViewController")
        }
        self.viewControllers = [viewController]
    }

    deinit {
        self.viewModel.stopObserving()
    }
}
