//
//  TestProfileTableViewModel.swift
//  POSClientTests
//
//  Created by Mederic Petit on 12/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient

class TestProfileTableViewModel: ProfileTableViewModelProtocol {
    var versionLabelText: String = "x"
    var settingsSectionTitle: String = "x"
    var infoSectionTitle: String = "x"
    var currentVersion: String = "x"
    var title: String = "x"
    var transactionLabelText: String = "x"
    var emailLabelText: String = "x"
    var signOutLabelText: String = "x"

    var onFailLogout: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?
    var shouldShowEnableConfirmationView: EmptyClosure?
    var onBioStateChange: ObjectClosure<Bool>?

    var switchState: Bool = false
    var isBiometricAvailable: Bool = false
    var touchFaceIdLabelText: String = "x"
    var emailValueLabelText: String = "x"

    func toggleSwitch(newValue isEnabled: Bool) {
        self.isToggleSwitchWithValue = isEnabled
    }

    func logout() {
        self.isLogoutCalled = true
    }

    func stopObserving() {
        self.isStopObservingCalled = true
    }

    var isToggleSwitchWithValue: Bool?
    var isLogoutCalled = false
    var isStopObservingCalled = false
}
