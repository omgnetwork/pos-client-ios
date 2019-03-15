//
//  UpdatePasswordViewModelProtocol.swift
//  POSClient
//
//  Created by Mederic Petit on 15/3/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

protocol UpdatePasswordViewModelProtocol {
    var updatePasswordValidation: ViewModelValidationClosure? { get set }
    var updatePasswordConfirmationValidation: ViewModelValidationClosure? { get set }
    var updatePasswordMatchingValidation: ViewModelValidationClosure? { get set }
    var onSuccessfulUpdate: ObjectClosure<String>? { get set }
    var onFailedUpdate: FailureClosure? { get set }
    var onLoadStateChange: ObjectClosure<Bool>? { get set }

    var title: String { get }
    var email: String { get }
    var token: String { get }
    var passwordPlaceholder: String { get }
    var passwordConfirmationPlaceholder: String { get }
    var passwordHint: String { get }
    var updateButtonTitle: String { get }

    var password: String? { get set }
    var passwordConfirmation: String? { get set }

    func update()
}
