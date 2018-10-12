//
//  SocketListener.swift
//  POSClient
//
//  Created by Mederic Petit on 12/10/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import OmiseGO

class SocketListener {
    static let shared: SocketListener = SocketListener()

    private let sessionManager: SessionManagerProtocol
    private var topic: String?

    init(sessionManager: SessionManagerProtocol = SessionManager.shared) {
        self.sessionManager = sessionManager
        self.sessionManager.attachObserver(observer: self)
    }

    private func startListening() {
        self.sessionManager.currentUser?.startListeningEvents(withClient: self.sessionManager.socketClient, eventDelegate: self)
    }

    private func stopListening() {
        guard let topic = self.topic else { return }
        self.sessionManager.socketClient.stopListening(topic: topic)
    }
}

extension SocketListener: UserEventDelegate {
    func on(_ object: WebsocketObject, error _: APIError?, forEvent event: SocketEvent) {
        switch (event, object) {
        case let (.transactionConsumptionRequest, .transactionConsumption(consumption)):
            NotificationCenter.default.post(name: .onConsumptionRequest, object: consumption)
        case let (.transactionConsumptionFinalized, .transactionConsumption(consumption)):
            NotificationCenter.default.post(name: .onConsumptionConfirmation, object: consumption)
        default: break
        }
    }

    func didStartListening() {
        print("Start listening")
    }

    func didStopListening() {
        print("Stop listening")
    }

    func onError(_ error: APIError) {
        print(error)
    }
}

extension SocketListener: Observer {
    func id() -> Int {
        return Int.random(in: 0 ..< 9_999_999_999_999)
    }

    func onChange(event: AppEvent) {
        switch event {
        case let .onUserUpdate(user: user) where user != nil:
            self.topic = user?.socketTopic
            self.startListening()
        case let .onUserUpdate(user: user) where user == nil:
            self.stopListening()
        default: break
        }
    }
}
