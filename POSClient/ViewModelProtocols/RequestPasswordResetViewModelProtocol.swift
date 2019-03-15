//
//  RequestPasswordResetViewModelProtocol.swift
//  POSClient
//
//  Created by Mederic Petit on 15/3/19.
//  Copyright © 2019 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

protocol RequestPasswordResetViewModelProtocol {
    var updateEmailValidation: ViewModelValidationClosure? { get set }
    var onSuccessRequest: ObjectClosure<String>? { get set }
    var onFailedRequest: FailureClosure? { get set }
    var onLoadStateChange: ObjectClosure<Bool>? { get set }

    var title: String { get }
    var emailPlaceholder: String { get }
    var requestButtonTitle: String { get }
    var hintString: String { get }

    var email: String? { get set }

    func requestReset()
}
