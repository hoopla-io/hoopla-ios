//
//  EndPoints.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import Foundation

enum EndPoints: String {
    
    // MARK: - Login
    case signIn = "auth/login"
    case resendSms = "auth/resend-sms"
    case confirmSms = "auth/confirm-sms"
    
    // MARK: - Main
    case partners = "partners"
    case nearShops = "shops/near-shops"
    case partner = "partners/partner"
    case partnerShops = "shops/partner-shops"
    case shop = "shops/shop"
    case createOrderRahmat = "user/orders/create-rahmat"
    case validateOrder = "user/orders/validate-order"
    case notificationsList = "notifications/get-list"
    case notificationShow = "notifications/show"
    
    // MARK: - History
    case ordersList = "user/orders/orders-list"
    case orders = "user/orders"
    case feedbacks = "orders/feedbacks"
    case pending = "orders/feedbacks/pending"
    
    // MARK: - Profile
    case getMe = "user/get-me"
    case editMe = "user/edit-me"
    case refreshToken = "user/refresh-token"
    case logout = "user/logout"
    case subscriptions = "subscriptions"
    case subscriptionsBuy = "subscriptions/buy"
    case deleteUser = "user/deactivate"
    case payServices = "user/pay/services"
    case topUp = "user/pay/top-up"
    case updateMe = "user/update-me"
}
