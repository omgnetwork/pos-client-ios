//
//  ProfileTableViewModelProtocol.swift
//  POSClient
//
//  Created by Mederic Petit on 12/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

protocol ProfileTableViewModelProtocol {
    var title: String { get }
    var transactionLabelText: String { get }
    var emailLabelText: String { get }
    var signOutLabelText: String { get }

    var onFailLogout: FailureClosure? { get set }
    var onLoadStateChange: ObjectClosure<Bool>? { get set }
    var shouldShowEnableConfirmationView: EmptyClosure? { get set }
    var onBioStateChange: ObjectClosure<Bool>? { get set }

    var switchState: Bool { get set }
    var isBiometricAvailable: Bool { get }
    var touchFaceIdLabelText: String { get }
    var emailValueLabelText: String { get }

    func toggleSwitch(newValue isEnabled: Bool)
    func logout()
    func stopObserving()
}
