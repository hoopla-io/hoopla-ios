//
//  OrderHistory.swift
//  qahvazor-client
//
//  Created by Alphazet on 12/01/25.
//

import Foundation

struct OrderHistory: Codable {
    let id: Int?
    let partnerName: String?
    let shopName: String?
    let drinks: [OrderHistoryDrink]?
    let purchasedAt: String?
    let drinkName: String?
    let productName: String?
    let orderStatus: String?
    let fiscalLink: String?
    let purchasedAtUnix: Int?
    let productPrice: Double?
    let cashbackEarned: Double?
    let cashbackUsed: Double?
    let shopIconUrl: String?
    let drinkImageUrl: String?
    let drinkImage: String?
    let productImageUrl: String?
    let checkoutUrl: String?
    let hasFeedback: Bool?
    let items: [OrderHistoryItem]?
}

struct OrderHistoryDrink: Codable {
    let drinkId: Int?
    let drinkName: String?
    let drinkPrice: Double?
    let status: String?
    let drinkImageUrl: String?
}

struct OrderHistoryItem: Codable {
    let id: Int?
    let itemType: String?
    let name: String?
    let price: Double?
    let quantity: Int?
    let imageUrl: String?
    let parentItemId: Int?
}

struct GetOrder: Codable {
    let expiresAt: Int?
    let orderId: Int?
    let token: String?
}
