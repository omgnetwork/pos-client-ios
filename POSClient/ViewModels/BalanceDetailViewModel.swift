//
//  BalanceDetailViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 20/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class BalanceDetailViewModel: BaseViewModel, BalanceDetailViewModelProtocol {
    var onPrimaryStateChange: EmptyClosure?
    var onFailGetWallet: FailureClosure?
    var onDataUpdate: SuccessClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    var balanceDisplay: String = "-"
    var tokenSymbol: String = "-"
    var title: String = ""
    let lastUpdatedString: String = "balance_detail.label.last_updated".localized()
    var lastUpdated: String = "-"
    var setPrimaryButtonTitle: String = "-"
    var isPrimary: Bool = false {
        didSet {
            self.onPrimaryStateChange?()
        }
    }

    let primaryTokenManager = PrimaryTokenManager()

    private var lastUpdatedDate: Date? {
        didSet {
            self.lastUpdated = self.lastUpdatedDate!.toString(withFormat: "MMM dd, yyyy HH:mm")
        }
    }

    lazy var payOrTopupAttrStr: NSAttributedString = {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        let pay = NSAttributedString(string: "balance_detail.label.pay".localized().uppercased() + "\n",
                                     attributes: [
                                         .font: Font.avenirHeavy.withSize(17),
                                         .foregroundColor: UIColor.white,
                                         .paragraphStyle: style
        ])
        let orTopup = NSAttributedString(string: "balance_detail.label.or_topup".localized(),
                                         attributes: [
                                             .font: Font.avenirMedium.withSize(12),
                                             .foregroundColor: UIColor.white,
                                             .paragraphStyle: style
        ])
        let payOrTopup = NSMutableAttributedString(attributedString: pay)
        payOrTopup.append(orTopup)
        return payOrTopup
    }()

    private var balance: Balance? {
        didSet {
            guard let balance = balance else {
                return
            }
            self.balanceDisplay = balance.displayAmount(withPrecision: 2)
            self.tokenSymbol = balance.token.symbol
            self.title = balance.token.name
            self.lastUpdatedDate = Date()
            self.onDataUpdate?()
        }
    }

    private let sessionManager: SessionManagerProtocol

    init(sessionManager: SessionManagerProtocol = SessionManager.shared,
         balance: Balance? = nil) {
        self.sessionManager = sessionManager
        self.balance = balance
        super.init()
        sessionManager.attachObserver(observer: self)
        self.updatePrimaryState()
        self.process(wallet: sessionManager.wallet)
    }

    @objc func loadData() {
        guard self.isLoading == false else { return }
        self.isLoading = true
        self.sessionManager.loadWallet()
    }

    func stopObserving() {
        self.sessionManager.removeObserver(observer: self)
    }

    func setPrimary() {
        guard let tokenId = self.balance?.token.id else { return }
        self.primaryTokenManager.setPrimary(tokenId: tokenId)
        self.updatePrimaryState()
    }

    private func updatePrimaryState() {
        if let balance = self.balance {
            if UserDefaultsWrapper().getValue(forKey: .primaryBalance) == balance.token.id {
                self.setPrimaryButtonTitle = "balance_detail.button.primary".localized()
                self.isPrimary = true
            } else {
                self.setPrimaryButtonTitle = "balance_detail.button.set_primary".localized()
                self.isPrimary = false
            }
        } else {
            self.setPrimaryButtonTitle = ""
            self.isPrimary = true
        }
    }

    private func process(wallet: Wallet?) {
        guard let wallet = wallet else { return }
        if let exitingBalance = self.balance, let updatedBalance = wallet.balances.filter({ $0 == exitingBalance }).first {
            self.balance = updatedBalance
        } else if wallet.balances.count == 1 {
            self.balance = wallet.balances.first!
        }
    }
}

extension BalanceDetailViewModel: Observer {
    func onChange(event: AppEvent) {
        switch event {
        case let .onWalletUpdate(wallet: wallet):
            self.process(wallet: wallet)
            self.isLoading = false
        case let .onWalletError(error: error):
            self.onFailGetWallet?(.omiseGO(error: error))
            self.isLoading = false
        default: break
        }
    }
}
