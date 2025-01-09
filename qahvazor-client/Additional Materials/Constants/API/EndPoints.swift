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
    case partner = "partners/partner"
    case partnerShops = "shops/partner-shops"
    case shop = "shops/shop"
    
    // MARK: - Profile
    case getMe = "user/get-me"
    case refreshToken = "user/refresh-token"
}
