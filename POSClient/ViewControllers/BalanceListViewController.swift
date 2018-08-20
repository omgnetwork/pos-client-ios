//
//  BalanceListViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 20/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class BalanceListViewController: BaseViewController {
    let balanceDetailSegueIdentifier = "showBalanceDetailViewController"
    let profileSegueIdentifier = "showProfileViewController"

    let viewModel: BalanceListViewModel = BalanceListViewModel()
    var refreshControl: UIRefreshControl!

    @IBOutlet var profileButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.viewTitle
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = Color.black.uiColor()
        self.refreshControl.addTarget(self.viewModel, action: #selector(self.viewModel.loadData), for: .valueChanged)
        self.tableView.registerNib(tableViewCell: BalanceTableViewCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.refreshControl = self.refreshControl
        self.viewModel.loadData()
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onTableDataChange = {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
        self.viewModel.onFailGetWallet = {
            self.showError(withMessage: $0.localizedDescription)
            self.refreshControl.endRefreshing()
        }
        self.viewModel.onLoadStateChange = { $0 ? self.showLoading() : self.hideLoading() }
        self.viewModel.onBalanceSelection = {
            self.performSegue(withIdentifier: self.balanceDetailSegueIdentifier, sender: $0)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.balanceDetailSegueIdentifier,
            let vc: BalanceDetailViewController = segue.destination as? BalanceDetailViewController,
            let balance: Balance = sender as? Balance {
            vc.setup(withBalance: balance)
        } else if segue.identifier == self.profileSegueIdentifier {
            // TODO: Handle navigation
        }
    }
}

extension BalanceListViewController {
    @IBAction func tapProfileButton(_: UIBarButtonItem) {
        // TODO: handle navigation
        SessionManager.shared.logout(withSuccessClosure: {
            (UIApplication.shared.delegate as? AppDelegate)?.loadRootView()
        }, failure: { error in
            print(error)
        })
    }
}

extension BalanceListViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.viewModel.numberOfRow()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: BalanceTableViewCell =
            tableView.dequeueReusableCell(withIdentifier: BalanceTableViewCell.identifier(),
                                          for: indexPath) as? BalanceTableViewCell else {
            return UITableViewCell()
        }
        cell.balanceTableViewModel = self.viewModel.cellViewModel(forIndex: indexPath.row)
        return cell
    }
}

extension BalanceListViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.didSelectBalance(atIndex: indexPath.row)
    }
}
