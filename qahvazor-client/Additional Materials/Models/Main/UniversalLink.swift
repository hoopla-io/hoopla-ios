//
//  UniversalLink.swift
//  qahvazor-client
//
//  Created by Alphazet on 23/06/25.
//

import Foundation

struct UniversalLink {
    static var shopId: Int?
    
    static func clear() {
        shopId = nil
    }
}

enum UniversalLinksType: String {
    case shop
}

