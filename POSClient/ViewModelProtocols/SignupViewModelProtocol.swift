//
//  SignupViewModelProtocol.swift
//  POSClient
//
//  Created by Mederic Petit on 12/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

protocol SignupViewModelProtocol {
    var updateEmailValidation: ViewModelValidationClosure? { get set }
    var updatePasswordValidation: ViewModelValidationClosure? { get set }
    var updatePasswordConfirmationValidation: ViewModelValidationClosure? { get set }
    var updatePasswordMatchingValidation: ViewModelValidationClosure? { get set }
    var onSuccessfulSignup: EmptyClosure? { get set }
    var onFailedSignup: FailureClosure? { get set }
    var onLoadStateChange: ObjectClosure<Bool>? { get set }

    var title: String { get }
    var emailPlaceholder: String { get }
    var passwordPlaceholder: String { get }
    var passwordConfirmationPlaceholder: String { get }
    var passwordHint: String { get }
    var terms: String { get }
    var signupButtonTitle: String { get }

    var email: String? { get set }
    var password: String? { get set }
    var passwordConfirmation: String? { get set }

    func signup()
}
