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
    
//    func saveTokens(data: Tokens) {
//        UserDefaults.standard.saveAccessToken(token: data.accessToken)
//        UserDefaults.standard.saveRefreshToken(token: data.refreshToken)
//    }
    
    func removeAccount() {
        removeAccessToken()
        removeRefreshToken()
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

