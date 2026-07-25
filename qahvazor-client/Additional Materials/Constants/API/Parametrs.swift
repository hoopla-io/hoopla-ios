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
    case categoryId = "categoryId"
    case partnerId = "partnerId"
    case shopId = "shopId"
    case long = "long"
    case lat = "lat"
    case name = "name"
    case drinkId = "drinkId"
    case modifiers = "modifiers"
    case modifierId = "modifierId"
    case modifierKey = "modifierKey"
    case modifierPrice = "modifierPrice"
    case notificationId = "notificationId"
    case modifierGroupId = "modifierGroupId"
    case use_cashback = "use_cashback"
    case cashback_amount = "cashback_amount"
    case order_id = "order_id"
    case rating = "rating"
    case comment = "comment"
    case promo_code = "promo_code"
    case quantity = "quantity"
    
    // MARK: - Profile
    case phoneNumber = "phoneNumber"
    case sessionId = "sessionId"
    case code = "code"
    case refreshToken = "refreshToken"
    case subscriptionId = "subscriptionId"
    case amount = "amount"
    case dateOfBirth = "dateOfBirth"
    case gender = "gender"
    
}
