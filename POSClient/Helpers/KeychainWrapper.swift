//
//  KeychainWrapper.swift
//  POSClient
//
//  Created by Mederic Petit on 28/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import KeychainAccess

class KeychainWrapper {
    let keychain = Keychain(service: "com.omisego.pos-client")

    func storePassword(password: String,
                       forKey key: KeychainKey,
                       success: @escaping SuccessClosure,
                       failure: @escaping FailureClosure) {
        dispatchGlobal {
            do {
                try self.keychain
                    .accessibility(.whenPasscodeSetThisDeviceOnly,
                                   authenticationPolicy: .userPresence)
                    .set(password, key: key.rawValue)
                dispatchMain {
                    success()
                }
            } catch {
                dispatchMain {
                    failure(POSClientError.other(error: error))
                }
            }
        }
    }

    func retrievePassword(withMessage message: String,
                          forKey key: KeychainKey,
                          success: @escaping ObjectClosure<String?>,
                          failure: @escaping FailureClosure) {
        dispatchGlobal {
            do {
                let password = try self.keychain
                    .authenticationPrompt(message)
                    .get(key.rawValue)
                dispatchMain {
                    success(password)
                }
            } catch {
                dispatchMain {
                    failure(POSClientError.other(error: error))
                }
            }
        }
    }

    func storeValue(value: String, forKey key: KeychainKey) {
        self.keychain[key.rawValue] = value
    }

    func getValue(forKey key: KeychainKey) -> String? {
        return self.keychain[key.rawValue]
    }

    func clearValue(forKey key: KeychainKey) {
        self.keychain[key.rawValue] = nil
    }
}
