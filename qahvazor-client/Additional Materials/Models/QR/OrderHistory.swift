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
    let purchasedAtUnix: Int?
}
