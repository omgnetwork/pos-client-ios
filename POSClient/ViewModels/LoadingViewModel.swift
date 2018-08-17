//
//  LoadingViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 17/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import UIKit

class LoadingViewModel: BaseViewModel {
    var onFailedLoading: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    let retryButtonTitle: String = "loading.button.title.retry".localized()

    private let sessionManager: SessionManagerProtocol

    init(sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
        super.init()
    }

    var isLoading: Bool = true {
        didSet {
            self.onLoadStateChange?(isLoading)
        }
    }

    func load() {
        self.isLoading = true
        self.sessionManager.loadCurrentUser(withSuccessClosure: {
            self.isLoading = false
            self.onAppStateChange?()
        }, failure: { error in
            self.handleOMGError(error)
            self.isLoading = false
            self.onFailedLoading?(POSClientError.omiseGO(error: error))
        })
    }
}
