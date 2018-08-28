//
//  SessionManager.swift
//  POSClient
//
//  Created by Mederic Petit on 17/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

protocol SessionManagerProtocol: Observable {
    var httpClient: HTTPClientAPI { get set }
    var currentUser: User? { get set }
    var wallet: Wallet? { get set }
    var isBiometricAvailable: Bool { get }
    func disableBiometricAuth()
    func enableBiometricAuth(withParams params: LoginParams, success: @escaping SuccessClosure, failure: @escaping FailureClosure)
    func bioLogin(withPromptMessage message: String, success: @escaping SuccessClosure, failure: @escaping FailureClosure)
    func login(withParams params: LoginParams, success: @escaping SuccessClosure, failure: @escaping FailureClosure)
    func logout(withSuccessClosure success: @escaping SuccessClosure, failure: @escaping FailureClosure)
    func signup(withParams params: SignupParams, success: @escaping SuccessClosure, failure: @escaping FailureClosure)
    func loadCurrentUser()
    func loadWallet()
}

class SessionManager: Publisher, SessionManagerProtocol {
    static let shared: SessionManager = SessionManager()
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

    var isBiometricAvailable: Bool {
        return self.userDefaultsWrapper.getBool(forKey: .biometricEnabled)
    }

    private let keychainWrapper = KeychainWrapper()
    private let userDefaultsWrapper = UserDefaultsWrapper()

    override init() {
        let authenticationToken = self.keychainWrapper.getValue(forKey: .authenticationToken)
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
        self.keychainWrapper.clearValue(forKey: .userId)
        self.keychainWrapper.clearValue(forKey: .authenticationToken)
        self.wallet = nil
        self.currentUser = nil
    }

    func disableBiometricAuth() {
        self.keychainWrapper.clearValue(forKey: .password)
        self.userDefaultsWrapper.clearValue(forKey: .biometricEnabled)
        self.notify(event: .onBioStateUpdate(enabled: false))
    }

    func enableBiometricAuth(withParams params: LoginParams, success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        self.login(withParams: params, success: {
            self.keychainWrapper.storePassword(password: params.password, forKey: .password, success: {
                self.userDefaultsWrapper.storeValue(value: true, forKey: .biometricEnabled)
                self.notify(event: .onBioStateUpdate(enabled: true))
                success()
            }, failure: failure)
        }, failure: failure)
    }

    func bioLogin(withPromptMessage message: String, success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        self.keychainWrapper.retrievePassword(withMessage: message, forKey: .password, success: { pw in
            guard let password = pw, !password.isEmpty,
                let email = self.userDefaultsWrapper.getValue(forKey: .email), !email.isEmpty else {
                failure(POSClientError.unexpected)
                return
            }
            let params = LoginParams(email: email, password: password)
            self.login(withParams: params, success: success, failure: failure)
        }, failure: failure)
    }

    func login(withParams params: LoginParams, success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        self.httpClient.login(withParams: params) { response in
            switch response {
            case let .fail(error: error): failure(.omiseGO(error: error))
            case let .success(data: authenticationToken):
                self.currentUser = authenticationToken.user
                self.keychainWrapper.storeValue(value: authenticationToken.user.id, forKey: .userId)
                self.keychainWrapper.storeValue(value: authenticationToken.token, forKey: .authenticationToken)
                self.userDefaultsWrapper.storeValue(value: params.email, forKey: .email)
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

    private func updateState() {
        if self.isLoggedIn() {
            self.state = (self.currentUser == nil || self.wallet == nil) ? .loading : .loggedIn
        } else {
            self.state = .loggedOut
        }
    }
}
