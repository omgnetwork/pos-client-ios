//
//  SessionManager.swift
//  POSClient
//
//  Created by Mederic Petit on 17/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import KeychainSwift
import OmiseGO

protocol SessionManagerProtocol {
    var httpClient: HTTPClientAPI { get set }
    var currentUser: User? { get set }

    func login(withParams params: LoginParams, success: @escaping SuccessClosure, failure: @escaping FailureClosure)
    func loadCurrentUser(withSuccessClosure success: @escaping SuccessClosure,
                         failure: @escaping (_ error: OMGError) -> Void)
    func logout(withSuccessClosure success: @escaping SuccessClosure, failure: @escaping FailureClosure)
}

class SessionManager: SessionManagerProtocol {
    static let shared: SessionManager = SessionManager()

    let keychain = KeychainSwift()

    var currentUser: User?
    var state: AppState {
        if self.isLoggedIn() {
            return self.currentUser == nil ? .loading : .loggedIn
        } else {
            return .loggedOut
        }
    }

    var httpClient: HTTPClientAPI

    init() {
        let authenticationToken = self.keychain.get(UserDefaultKeys.authenticationToken.rawValue)
        let credentials = ClientCredential(apiKey: Constant.APIKey,
                                           authenticationToken: authenticationToken)
        let httpConfig = ClientConfiguration(baseURL: Constant.baseURL,
                                             credentials: credentials,
                                             debugLog: true)
        self.httpClient = HTTPClientAPI(config: httpConfig)
    }

    func isLoggedIn() -> Bool {
        return self.httpClient.isAuthenticated
    }

    func clearTokens() {
        self.keychain.delete(UserDefaultKeys.userId.rawValue)
        self.keychain.delete(UserDefaultKeys.authenticationToken.rawValue)
        self.currentUser = nil
    }

    private func loadTokens() {
    }

    private func initializeOmiseGOSDK() {
    }

    // SessionManagerProtocol
    func login(withParams params: LoginParams, success: @escaping SuccessClosure, failure: @escaping FailureClosure) {
        self.httpClient.login(withParams: params) { response in
            switch response {
            case let .fail(error: error): failure(.omiseGO(error: error))
            case let .success(data: authenticationToken):
                self.currentUser = authenticationToken.user
                self.keychain.set(authenticationToken.user.id, forKey: UserDefaultKeys.userId.rawValue)
                self.keychain.set(authenticationToken.token, forKey: UserDefaultKeys.authenticationToken.rawValue)
                success()
            }
        }
    }

    func loadCurrentUser(withSuccessClosure success: @escaping SuccessClosure,
                         failure: @escaping (_ error: OMGError) -> Void) {
        guard self.isLoggedIn() else {
            failure(.unexpected(message: "error.unexpected".localized()))
            return
        }
        User.getCurrent(using: self.httpClient) { response in
            switch response {
            case let .success(data: user):
                self.currentUser = user
                success()
            case let .fail(error: error):
                failure(error)
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
}

extension SessionManager: SocketConnectionDelegate {
    func didConnect() {
        print("Socket did connect")
    }

    func didDisconnect(_: OMGError?) {
        print("Socket did disconnect")
    }
}
