//
//  MainTabBarViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 24/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import NotificationBannerSwift
import OmiseGO

class BannerColor: BannerColorsProtocol {
    func color(for _: BannerStyle) -> UIColor {
        return Color.omiseGOBlue.uiColor()
    }
}

class MainTabBarViewController: UITabBarController {
    let consumptionConfirmationSegueIdentifier = "consumptionConfirmationSegueIdentifier"
    let viewModel: MainTabBarViewModel = MainTabBarViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.onTabSelected = { [weak self] tabIndex in
            self?.selectedIndex = tabIndex
        }
        self.viewModel.onConsumptionRequest = { [weak self] in
            guard let self = self else { return }
            self.performSegue(withIdentifier: self.consumptionConfirmationSegueIdentifier, sender: $0)
        }
        self.viewModel.onConsumptionFinalized = { [weak self] in
            let banner = NotificationBanner(attributedTitle: $0.title, attributedSubtitle: $0.subtitle, style: .info, colors: BannerColor())
            banner.onTap = {
                self?.showTransactionHistory()
            }
            banner.show()
        }
        self.viewModel.onConsumptionRejected = { [weak self] in
            self?.presentedViewController?.dismiss(animated: true, completion: nil)
        }
        self.setTabBarItems()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.consumptionConfirmationSegueIdentifier,
            let consumptionConfirmationVC = segue.destination as? ConsumptionConfirmationViewController,
            let consumption = sender as? TransactionConsumption {
            consumptionConfirmationVC.viewModel = ConsumptionConfirmationViewModel(consumption: consumption)
        }
    }

    func setTabBarItems() {
        if let item1 = self.viewControllers?[0].tabBarItem {
            item1.image = self.viewModel.item1Image
            item1.title = self.viewModel.item1Title
        }
        if let item2 = self.viewControllers?[1].tabBarItem {
            item2.image = self.viewModel.item2Image
            item2.title = self.viewModel.item2Title
        }
        if let item3 = self.viewControllers?[2].tabBarItem {
            item3.image = self.viewModel.item3Image
            item3.title = self.viewModel.item3Title
        }
    }

    func showTransactionHistory() {
        guard let profileNavVC = self.viewControllers?[2] as? UINavigationController,
            let transactionVC = TransactionsViewController.initWithViewModel(),
            let profileVC = profileNavVC.viewControllers[0] as? ProfileTableViewController else {
            return
        }
        profileNavVC.viewControllers = [profileVC, transactionVC]
        self.selectedIndex = 2
    }
}
