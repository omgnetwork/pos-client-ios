//
//  TestSignupViewModel.swift
//  POSClientTests
//
//  Created by Mederic Petit on 12/9/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

@testable import POSClient

class TestSignupViewModel: SignupViewModelProtocol {
    var updateEmailValidation: ViewModelValidationClosure?
    var updatePasswordValidation: ViewModelValidationClosure?
    var updatePasswordConfirmationValidation: ViewModelValidationClosure?
    var updatePasswordMatchingValidation: ViewModelValidationClosure?
    var onSuccessfulSignup: EmptyClosure?
    var onFailedSignup: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    var title: String = "x"
    var emailPlaceholder: String = "x"
    var passwordPlaceholder: String = "x"
    var passwordConfirmationPlaceholder: String = "x"
    var passwordHint: String = "x"
    var terms: String = "x"
    var signupButtonTitle: String = "x"

    var email: String?
    var password: String?
    var passwordConfirmation: String?

    func signup() {
        self.isSignupCalled = true
    }

    var isSignupCalled = false
}
