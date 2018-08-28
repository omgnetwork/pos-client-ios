//
//  TransactionsViewController.swift
//  POSClient
//
//  Created by Mederic Petit on 24/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class TransactionsViewController: BaseTableViewController {
    let viewModel: TransactionsViewModel = TransactionsViewModel()

    lazy var loadingView: UIView = {
        let loader = UIActivityIndicatorView(activityIndicatorStyle: .white)
        loader.startAnimating()
        loader.translatesAutoresizingMaskIntoConstraints = false
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 44))
        view.addSubview(loader)
        [.centerX, .centerY].forEach({
            view.addConstraint(NSLayoutConstraint(item: loader,
                                                  attribute: $0,
                                                  relatedBy: .equal,
                                                  toItem: view,
                                                  attribute: $0,
                                                  multiplier: 1,
                                                  constant: 0))
        })
        return view
    }()

    override func configureView() {
        super.configureView()
        self.title = self.viewModel.viewTitle
        self.refreshControl?.addTarget(self, action: #selector(self.reloadTransactions), for: .valueChanged)
        self.tableView.registerNib(tableViewCell: TransactionTableViewCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 62
        self.tableView.refreshControl = self.refreshControl
        self.reloadTransactions()
        self.tableView.contentInsetAdjustmentBehavior = .never
    }

    override func configureViewModel() {
        super.configureViewModel()
        self.viewModel.onLoadStateChange = { [weak self] in
            self?.tableView.tableFooterView = $0 ? self?.loadingView : UIView()
        }
        self.viewModel.reloadTableViewClosure = { [weak self] in
            self?.tableView.reloadData()
            self?.refreshControl?.endRefreshing()
        }
        self.viewModel.onFailLoadTransactions = { [weak self] in
            self?.showError(withMessage: $0.localizedDescription)
            self?.refreshControl?.endRefreshing()
        }
        self.viewModel.appendNewResultClosure = { [weak self] indexPaths in
            UIView.setAnimationsEnabled(false)
            self?.tableView.beginUpdates()
            self?.tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.none)
            self?.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }

    @objc private func reloadTransactions() {
        self.viewModel.reloadTransactions()
    }
}

extension TransactionsViewController {
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.viewModel.numberOfRow()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: TransactionTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: TransactionTableViewCell.identifier(),
            for: indexPath) as? TransactionTableViewCell else {
            return UITableViewCell()
        }
        cell.transactionCellViewModel = self.viewModel.transactionCellViewModel(at: indexPath)
        return cell
    }
}

extension TransactionsViewController {
    override func tableView(_: UITableView, willDisplay _: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.viewModel.shouldLoadNext(atIndexPath: indexPath) {
            self.viewModel.getNextTransactions()
        }
    }
}
