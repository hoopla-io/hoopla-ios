//
//  Parametrs.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import Foundation

enum Parameters: String {
    // MARK: - Meta
    case itemsPerPage = "itemsPerPage"
    case page = "page"
    
    // MARK: - Main
    case id = "id"
    case partnerId = "partnerId"
    case shopId = "shopId"
    
    // MARK: - Profile
    case phoneNumber = "phoneNumber"
    case sessionId = "sessionId"
    case code = "code"
    case refreshToken = "refreshToken"
}
