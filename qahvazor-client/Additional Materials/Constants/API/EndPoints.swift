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
    case qrCode = "user/generate-qr-code"
    case orders = "user/orders/orders-list"
    
    // MARK: - Profile
    case getMe = "user/get-me"
    case refreshToken = "user/refresh-token"
    case logout = "user/logout"
    case subscriptions = "subscriptions"
}
