//
//  ProfileTableViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 23/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class ProfileTableViewModel: BaseViewModel {
    let title = "profile.view.title".localized()
    let transactionLabelText = "profile.label.transactions".localized()
    let emailLabelText = "profile.label.email".localized()
    let touchFaceIdLabelText = "profile.label.touchFaceID".localized()
    let signOutLabelText = "profile.label.signout".localized()

    var onFailLogout: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    var switchState: Bool = false

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    lazy var isBioEnable: Bool = false

    lazy var emailValueLabelText: String = {
        self.sessionManager.currentUser?.email ?? ""
    }()

    private let sessionManager: SessionManagerProtocol

    init(sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
        super.init()
    }

    func toggleSwitch(newValue _: Bool) {}

    func logout() {
        self.isLoading = true
        self.sessionManager.logout(withSuccessClosure: {}, failure: { [weak self] error in
            self?.isLoading = false
            self?.onFailLogout?(error)
        })
    }
}
