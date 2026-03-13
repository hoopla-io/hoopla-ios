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
    let drinkName: String?
    let orderStatus: String?
    let fiscalLink: String?
    let purchasedAtUnix: Int?
    let productPrice: Double?
    let cashbackEarned: Double?
    let cashbackUsed: Double?
    let shopIconUrl: String?
    let drinkImageUrl: String?
    let checkoutUrl: String?
    let items: [OrderHistoryItem]?
}

struct OrderHistoryItem: Codable {
    let itemType: String?
    let name: String?
    let price: Double?
}
