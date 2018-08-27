//
//  SessionManager.swift
//  POSClient
//
//  Created by Mederic Petit on 17/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import KeychainAccess
import OmiseGO

protocol SessionManagerProtocol: Observable {
    var httpClient: HTTPClientAPI { get set }
    var currentUser: User? { get set }
    var wallet: Wallet? { get set }
    func login(withParams params: LoginParams, success: @escaping SuccessClosure, failure: @escaping FailureClosure)
    func logout(withSuccessClosure success: @escaping SuccessClosure, failure: @escaping FailureClosure)
    func signup(withParams params: SignupParams, success: @escaping SuccessClosure, failure: @escaping FailureClosure)
    func loadCurrentUser()
    func loadWallet()
}

class SessionManager: Publisher, SessionManagerProtocol {
    static let shared: SessionManager = SessionManager()

    let keychain = Keychain(service: "com.omisego.pos-client")
    var state: AppState! {
        didSet {
            if oldValue != self.state {
                self.notify(event: .onAppStateUpdate(state: self.state))
            }
        }
    }

    var currentUser: User? {
        didSet {
            self.updateState()
            self.notify(event: .onUserUpdate(user: self.currentUser))
        }
    }

    var wallet: Wallet? {
        didSet {
            self.updateState()
            self.notify(event: .onWalletUpdate(wallet: self.wallet))
        }
    }

    var httpClient: HTTPClientAPI

    override init() {
        let authenticationToken = self.keychain[UserDefaultKeys.authenticationToken.rawValue]
        let credentials = ClientCredential(apiKey: Constant.APIKey,
                                           authenticationToken: authenticationToken)
        let httpConfig = ClientConfiguration(baseURL: Constant.baseURL,
                                             credentials: credentials,
                                             debugLog: false)
        self.httpClient = HTTPClientAPI(config: httpConfig)
        super.init()
        self.updateState()
    }

    func isLoggedIn() -> Bool {
        return self.httpClient.isAuthenticated
    }

    func clearTokens() {
        self.keychain[UserDefaultKeys.userId.rawValue] = nil
        self.keychain[UserDefaultKeys.authenticationToken.rawValue] = nil
        self.wallet = nil
        self.currentUser = nil
    }

    private func updateState() {
        if self.isLoggedIn() {
            self.state = (self.currentUser == nil || self.wallet == nil) ? .loading : .loggedIn
        } else {
            self.state = .loggedOut
        }
    }

    func login(withParams params: LoginParams, success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        self.httpClient.login(withParams: params) { response in
            switch response {
            case let .fail(error: error): failure(.omiseGO(error: error))
            case let .success(data: authenticationToken):
                self.currentUser = authenticationToken.user
                self.keychain[UserDefaultKeys.userId.rawValue] = authenticationToken.user.id
                self.keychain[UserDefaultKeys.authenticationToken.rawValue] = authenticationToken.token
                success()
            }
        }
    }

    func logout(withSuccessClosure success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        self.httpClient.logout { response in
            switch response {
            case .success(data: _):
                self.clearTokens()
                success()
            case let .fail(error: error):
                failure(.omiseGO(error: error))
            }
        }
    }

    func signup(withParams params: SignupParams, success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        self.httpClient.signup(withParams: params) { response in
            switch response {
            case .success: success()
            case let .fail(error: error): failure(.omiseGO(error: error))
            }
        }
    }

    func loadCurrentUser() {
        User.getCurrent(using: self.httpClient) { response in
            switch response {
            case let .success(data: user):
                self.currentUser = user
            case let .fail(error: error):
                self.notify(event: .onUserError(error: error))
            }
        }
    }

    func loadWallet() {
        Wallet.getMain(using: self.httpClient) { response in
            switch response {
            case let .success(data: wallet):
                self.wallet = wallet
            case let .fail(error: error):
                self.notify(event: .onWalletError(error: error))
            }
        }
    }
}
