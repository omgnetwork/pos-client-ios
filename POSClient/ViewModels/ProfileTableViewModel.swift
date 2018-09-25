//
//  ProfileTableViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 23/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class ProfileTableViewModel: BaseViewModel, ProfileTableViewModelProtocol {
    let title = "profile.view.title".localized()
    let transactionLabelText = "profile.label.transactions".localized()
    let emailLabelText = "profile.label.email".localized()
    let signOutLabelText = "profile.label.signout".localized()

    var onFailLogout: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?
    var shouldShowEnableConfirmationView: EmptyClosure?
    var onBioStateChange: ObjectClosure<Bool>?

    var switchState: Bool {
        didSet {
            self.onBioStateChange?(self.switchState)
        }
    }

    var isLoading: Bool = false {
        didSet { self.onLoadStateChange?(isLoading) }
    }

    lazy var isBiometricAvailable: Bool = {
        self.biometric.biometricType() != .none
    }()

    lazy var touchFaceIdLabelText = {
        self.biometric.biometricType().name
    }()

    lazy var emailValueLabelText: String = {
        self.sessionManager.currentUser?.email ?? ""
    }()

    private let sessionManager: SessionManagerProtocol
    private let biometric = BiometricIDAuth()

    init(sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
        self.switchState = sessionManager.isBiometricAvailable
        super.init()
        sessionManager.attachObserver(observer: self)
    }

    func toggleSwitch(newValue isEnabled: Bool) {
        isEnabled ? self.shouldShowEnableConfirmationView?() : self.sessionManager.disableBiometricAuth()
    }

    func logout() {
        self.isLoading = true
        self.sessionManager.logout(false, success: {}, failure: { [weak self] error in
            self?.isLoading = false
            self?.onFailLogout?(error)
        })
    }

    func stopObserving() {
        self.sessionManager.removeObserver(observer: self)
    }
}

extension ProfileTableViewModel: Observer {
    func onChange(event: AppEvent) {
        switch event {
        case let .onBioStateUpdate(enabled: enabled):
            self.switchState = enabled
        default: break
        }
    }
}
