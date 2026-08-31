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
    case partnersList = "partners/list"
    case partnersShops = "partners/shops"
    case nearShops = "shops/near-shops"
    case partner = "partners/partner"
    case partnerShops = "shops/partner-shops"
    case shop = "shops/shop"
    case drinks = "shops/drinks"
    case createOrder = "user/orders/create"
    case activeOrders = "user/orders/active"
    case checkPromocode = "user/orders/check-promocode"
    case validateOrder = "user/orders/validate-order"
    case cart = "user/cart"
    case cartCount = "user/cart/count"
    case cartItems = "user/cart/items"
    case cartPromo = "user/cart/promo"
    case cartComment = "user/cart/comment"
    case cartCheckout = "user/orders/cart-checkout"
    case notificationsList = "notifications/list"
    case notificationShow = "notifications/show"
    case categories = "categories/list"
    case storiesList = "stories/list"
    
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
    case devices = "user/devices"
    case subscriptions = "subscriptions"
    case subscriptionsBuy = "subscriptions/buy"
    case deleteUser = "user/deactivate"
    case payServices = "user/pay/services"
    case topUp = "user/pay/top-up"
    case updateMe = "user/update-me"
    case redeemGiftcard = "user/gift-cards/redeem"
}
