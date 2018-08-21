//
//  LoadingViewModel.swift
//  POSClient
//
//  Created by Mederic Petit on 17/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class LoadingViewModel: BaseViewModel {
    var onFailedLoading: FailureClosure?
    var onLoadStateChange: ObjectClosure<Bool>?

    let dispatchGroup: DispatchGroup = DispatchGroup()
    let retryButtonTitle: String = "loading.button.title.retry".localized()

    var raisedError: OMGError?
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
        self.sessionManager.attachObserver(observer: self)
        self.raisedError = nil
        self.isLoading = true
        self.dispatchGroup.enter()
        self.sessionManager.loadCurrentUser()
        self.dispatchGroup.enter()
        self.sessionManager.loadWallet()
        DispatchQueue.global().async {
            self.dispatchGroup.wait()
            dispatchMain {
                self.isLoading = false
                self.sessionManager.removeObserver(observer: self)
                if let error = self.raisedError {
                    self.handleOMGError(error)
                    self.onFailedLoading?(POSClientError.omiseGO(error: error))
                } else {
                    self.onAppStateChange?()
                }
            }
        }
    }
}

extension LoadingViewModel: Observer {
    func onChange(event: AppEvent) {
        switch event {
        case let .onUserError(error: error):
            self.raisedError = error
            self.dispatchGroup.leave()
        case let .onWalletError(error: error):
            self.raisedError = error
            self.dispatchGroup.leave()
        case .onWalletUpdate, .onUserUpdate:
            self.dispatchGroup.leave()
        default: break
        }
    }
}
