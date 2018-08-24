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

    @IBOutlet var tableView: UITableView!

    override func configureView() {
        super.configureView()
        self.navigationItem.title = self.viewModel.viewTitle
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = Color.black.uiColor()
        self.refreshControl.addTarget(self.viewModel, action: #selector(self.viewModel.loadData), for: .valueChanged)
        self.tableView.registerNib(tableViewCell: BalanceTableViewCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.refreshControl = self.refreshControl
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onTableDataChange = { [weak self] in
            self?.tableView.reloadData()
            self?.refreshControl.endRefreshing()
        }
        self.viewModel.onFailGetWallet = { [weak self] in
            self?.showError(withMessage: $0.localizedDescription)
            self?.refreshControl.endRefreshing()
        }
        self.viewModel.onBalanceSelection = { [weak self] in
            guard let weakself = self else { return }
            weakself.performSegue(withIdentifier: weakself.balanceDetailSegueIdentifier, sender: $0)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == self.balanceDetailSegueIdentifier,
            let vc: BalanceDetailViewController = segue.destination as? BalanceDetailViewController,
            let balance: Balance = sender as? Balance {
            vc.setup(withBalance: balance)
        }
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
