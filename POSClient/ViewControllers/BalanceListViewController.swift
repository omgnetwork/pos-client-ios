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

    private var viewModel: BalanceListViewModelProtocol = BalanceListViewModel()
    var refreshControl: UIRefreshControl!

    @IBOutlet var tableView: UITableView!

    class func initWithViewModel(_ viewModel: BalanceListViewModelProtocol = BalanceListViewModel()) -> BalanceListViewController? {
        guard let balanceListVC: BalanceListViewController = Storyboard.balance.viewControllerFromId() else { return nil }
        balanceListVC.viewModel = viewModel
        return balanceListVC
    }

    override func configureView() {
        super.configureView()
        self.navigationItem.title = self.viewModel.viewTitle
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = Color.black.uiColor()
        self.refreshControl.addTarget(self, action: #selector(self.loadDataBridge), for: .valueChanged)
        self.tableView.registerNib(tableViewCell: BalanceTableViewCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedRowHeight = 72
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

    @objc private func loadDataBridge() {
        self.viewModel.loadData()
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
