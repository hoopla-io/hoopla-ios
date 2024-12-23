//
//  Local.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import Foundation

enum Local: LocalizedString {
    case home
    case catalog
    case tv
    case search
    case library
    case profile
    
    // MARK: - Profile
    case account
    
    var localized: String {
        return self.rawValue.v
    }
}
