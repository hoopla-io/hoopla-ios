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
}

extension UserDefaults {
    func getLocalization() -> String {
        return string(forKey: UserDefaultsKeys.localization.rawValue) ?? (Locale.current.languageCode ?? AppLanguage.uz.rawValue)
    }

    func saveLocalization(lang: String) {
        set(lang, forKey: UserDefaultsKeys.localization.rawValue)
    }
    
    func setLastFocuasedTimeShiftBar(indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        let array = [indexPath.row, indexPath.section]
        set(array, forKey: UserDefaultsKeys.localization.rawValue)
    }
    
    func getLastFocuasedTimeShiftBar() -> [Any]? {
        return array(forKey: UserDefaultsKeys.localization.rawValue)
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

