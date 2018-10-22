//
//  TestSessionManager.swift
//  POSClientTests
//
//  Created by Mederic Petit on 31/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO
@testable import POSClient

class TestSessionManager: Publisher, SessionManagerProtocol {
    var httpClient: HTTPClientAPI!
    var currentUser: User?
    var wallet: Wallet?
    var isBiometricAvailable: Bool

    init(httpClient: HTTPClientAPI? = nil,
         currentUser: User? = nil,
         wallet: Wallet? = nil,
         isBiometricAvailable: Bool = false) {
        if let client = httpClient {
            self.httpClient = client
        } else {
            let clientCredential = ClientCredential(apiKey: "123", authenticationToken: "123")
            let clientConfiguration = ClientConfiguration(baseURL: "http://localhost:4000", credentials: clientCredential)
            self.httpClient = HTTPClientAPI(config: clientConfiguration)
        }
        self.currentUser = currentUser
        self.wallet = wallet
        self.isBiometricAvailable = isBiometricAvailable
    }

    var disableBiometricAuthCalled: Bool = false
    var enableBiometricAuthCalled: Bool = false
    var bioLoginCalled: Bool = false
    var loginCalled: Bool = false
    var logoutCalled: Bool = false
    var signupCalled: Bool = false
    var loadCurrentUserCalled: Bool = false
    var loadWalletCalled: Bool = false
    var attachObserverCalled: Bool = false
    var removeObserverCalled: Bool = false
    var notifyCalled: Bool = false
    var clearTokenCalled: Bool = false
    var isForceLogout: Bool = false

    private var enableBiometricAuthSuccessClosure: SuccessClosure?
    private var enableBiometricAuthFailureClosure: FailureClosure?
    private var bioLoginSuccessClosure: SuccessClosure?
    private var bioLoginFailureClosure: FailureClosure?
    private var loginSuccessClosure: SuccessClosure?
    private var loginFailureClosure: FailureClosure?
    private var logoutSuccessClosure: SuccessClosure?
    private var logoutFailureClosure: FailureClosure?
    private var signupSuccessClosure: SuccessClosure?
    private var signupFailureClosure: FailureClosure?

    func loadCurrentUserSuccess() {
        self.currentUser = StubGenerator.currentUser()
        self.notify(event: .onUserUpdate(user: self.currentUser))
    }

    func loadCurrentUserFailed(withError error: OMGError) {
        self.currentUser = nil
        self.notify(event: .onUserError(error: error))
    }

    func loadWalletSuccess() {
        self.wallet = StubGenerator.mainWallet()
        self.notify(event: .onWalletUpdate(wallet: self.wallet))
    }

    func loadWalletFailed(withError error: OMGError) {
        self.wallet = nil
        self.notify(event: .onWalletError(error: error))
    }

    func enableBiometricAuthSuccss() {
        self.isBiometricAvailable = true
        self.enableBiometricAuthSuccessClosure?()
    }

    func enableBiometricAuthFailed(withError error: OMGError) {
        self.enableBiometricAuthFailureClosure?(.omiseGO(error: error))
        self.notify(event: .onBioStateUpdate(enabled: true))
    }

    func bioLoginSuccess() {
        self.bioLoginSuccessClosure?()
    }

    func bioLoginFailed(withError error: OMGError) {
        self.bioLoginFailureClosure?(.omiseGO(error: error))
    }

    func loginSuccess() {
        self.loginSuccessClosure?()
    }

    func loginFailed(withError error: OMGError) {
        self.loginFailureClosure?(.omiseGO(error: error))
    }

    func logoutSuccess() {
        self.logoutSuccessClosure?()
    }

    func logoutFailure(withError error: OMGError) {
        self.logoutFailureClosure?(.omiseGO(error: error))
    }

    func signupSuccess() {
        self.signupSuccessClosure?()
    }

    func signupFailure(withError error: OMGError) {
        self.signupFailureClosure?(.omiseGO(error: error))
    }

    func disableBiometricAuth() {
        self.disableBiometricAuthCalled = true
        self.notify(event: .onBioStateUpdate(enabled: false))
    }

    func enableBiometricAuth(withParams _: LoginParams, success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        self.enableBiometricAuthCalled = true
        self.enableBiometricAuthSuccessClosure = success
        self.enableBiometricAuthFailureClosure = failure
    }

    func bioLogin(withPromptMessage _: String, success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        self.bioLoginCalled = true
        self.bioLoginSuccessClosure = success
        self.bioLoginFailureClosure = failure
    }

    func login(withParams _: LoginParams, success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        self.loginCalled = true
        self.loginSuccessClosure = success
        self.loginFailureClosure = failure
    }

    func logout(_ force: Bool, success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        self.isForceLogout = force
        self.logoutCalled = true
        self.logoutSuccessClosure = success
        self.logoutFailureClosure = failure
    }

    func signup(withParams _: SignupParams, success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        self.signupCalled = true
        self.signupSuccessClosure = success
        self.signupFailureClosure = failure
    }

    func loadCurrentUser() {
        self.loadCurrentUserCalled = true
    }

    func loadWallet() {
        self.loadWalletCalled = true
    }

    func clearTokens() {
        self.clearTokenCalled = true
    }

    override func attachObserver(observer: Observer) {
        super.attachObserver(observer: observer)
        self.attachObserverCalled = true
    }

    override func removeObserver(observer: Observer) {
        super.removeObserver(observer: observer)
        self.removeObserverCalled = true
    }

    override func notify(event: AppEvent) {
        super.notify(event: event)
        self.notifyCalled = true
    }
}
