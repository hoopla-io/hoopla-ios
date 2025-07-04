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
    case long = "long"
    case lat = "lat"
    case name = "name"
    case drinkId = "drinkId"
    
    // MARK: - Profile
    case phoneNumber = "phoneNumber"
    case sessionId = "sessionId"
    case code = "code"
    case refreshToken = "refreshToken"
    case subscriptionId = "subscriptionId"
    case amount = "amount"
    
}
