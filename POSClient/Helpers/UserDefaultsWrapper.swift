//
//  UserDefaultsWrapper.swift
//  POSClient
//
//  Created by Mederic Petit on 28/8/18.
//  Copyright © 2018 Omise Go Pte. Ltd. All rights reserved.
//

import Foundation

class UserDefaultsWrapper {
    let userDefaults = UserDefaults()

    func storeValue(value: String, forKey key: UserDefaultKey) {
        self.userDefaults.set(value, forKey: key.rawValue)
    }

    func storeValue(value: Bool, forKey key: UserDefaultKey) {
        self.userDefaults.set(value, forKey: key.rawValue)
    }

    func getBool(forKey key: UserDefaultKey) -> Bool {
        return self.userDefaults.bool(forKey: key.rawValue)
    }

    func getValue(forKey key: UserDefaultKey) -> String? {
        return self.userDefaults.string(forKey: key.rawValue)
    }

    func storeData(data: Data, forKey key: UserDefaultKey) {
        self.userDefaults.set(data, forKey: key.rawValue)
    }

    func getData(forKey key: UserDefaultKey) -> Data? {
        return self.userDefaults.data(forKey: key.rawValue)
    }

    func clearValue(forKey key: UserDefaultKey) {
        self.userDefaults.removeObject(forKey: key.rawValue)
    }
}
