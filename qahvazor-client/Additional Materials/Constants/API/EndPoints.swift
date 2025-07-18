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
    case createOrder = "user/orders/create"
    
    // MARK: - QR
    case qrCode = "user/generate-qr-code"
    case orders = "user/orders/orders-list"
    case drinksLimit = "user/orders/drinks-stat"
    
    // MARK: - Profile
    case getMe = "user/get-me"
    case refreshToken = "user/refresh-token"
    case logout = "user/logout"
    case subscriptions = "subscriptions"
    case subscriptionsBuy = "subscriptions/buy"
    case deleteUser = "user/deactivate"
    case payServices = "user/pay/services"
    case topUp = "user/pay/top-up"
}
