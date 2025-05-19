//
//  UserDefaults.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import Foundation

enum AppLanguage: String {
    case ru
    case uz
    case en
}

enum UserDefaultsKeys: String {
    case localization
    case accessToken
    case refreshToken
    case firstLaunch
    case latitude
    case longitude
    case balance
}

extension UserDefaults {
    
    func getLocalization() -> String {
        return string(forKey: UserDefaultsKeys.localization.rawValue) ?? AppLanguage.uz.rawValue
    }

    func saveLocalization(lang: String) {
        set(lang, forKey: UserDefaultsKeys.localization.rawValue)
    }
    
    func saveAccessToken(token: String?) {
        set(token, forKey: UserDefaultsKeys.accessToken.rawValue)
    }
    
    func accessToken() -> String? {
        return string(forKey: UserDefaultsKeys.accessToken.rawValue)
    }
    
    func removeAccessToken() {
        removeObject(forKey: UserDefaultsKeys.accessToken.rawValue)
    }
    
    func saveRefreshToken(token: String?) {
        set(token, forKey: UserDefaultsKeys.refreshToken.rawValue)
    }
    
    func refreshToken() -> String? {
        return string(forKey: UserDefaultsKeys.refreshToken.rawValue)
    }
    
    func removeRefreshToken() {
        removeObject(forKey: UserDefaultsKeys.refreshToken.rawValue)
    }
    
    func isAuthed() -> Bool {
        return accessToken() != nil ? true : false
    }
    
    func saveNotFirstLaunch(_ value: Bool) {
        set(value, forKey: UserDefaultsKeys.firstLaunch.rawValue)
    }
    
    func isNotFirstLaunch() -> Bool {
        return bool(forKey: UserDefaultsKeys.firstLaunch.rawValue)
    }
    
    func saveTokens(data: Tokens) {
        UserDefaults.standard.saveAccessToken(token: data.accessToken)
        UserDefaults.standard.saveRefreshToken(token: data.refreshToken)
    }
    
    func saveLongitude(_ longitude: Double) {
        set(longitude, forKey: UserDefaultsKeys.longitude.rawValue)
    }
    
    func getLongitude() -> Double {
        return double(forKey: UserDefaultsKeys.longitude.rawValue)
    }
    
    func saveLatitude(_ longitude: Double) {
        set(longitude, forKey: UserDefaultsKeys.latitude.rawValue)
    }
    
    func getLatitude() -> Double {
        return double(forKey: UserDefaultsKeys.latitude.rawValue)
    }
    
    func removeAccount() {
        removeAccessToken()
        removeRefreshToken()
    }
    
    func saveBalance(_ amount: Double) {
        set(amount, forKey: UserDefaultsKeys.balance.rawValue)
    }
    
    func getBalance() -> Double {
        return double(forKey: UserDefaultsKeys.balance.rawValue)
    }
}


extension UserDefaults {
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}

