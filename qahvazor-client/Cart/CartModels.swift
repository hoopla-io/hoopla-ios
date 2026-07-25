//
//  CartModels.swift
//  qahvazor-client
//

import Foundation

struct Cart: Decodable {
    let id: Int?
    let shopId: Int?
    let partnerId: Int?
    let status: String?
    let promoCode: String?
    let comment: String?
    let items: [CartItem]?
    let subtotal: Double?
    let promoDiscount: Double?
    let total: Double?
    let createdAt: String?
    let updatedAt: String?

    var itemCount: Int {
        items?.reduce(0) { $0 + max($1.quantity ?? 0, 0) } ?? 0
    }
}

struct CartItem: Decodable {
    let id: Int?
    let drinkId: Int?
    let name: String?
    let quantity: Int?
    let unitPrice: Double?
    let lineTotal: Double?
    let modifiers: [CartItemModifier]?
}

struct CartItemModifier: Decodable {
    let name: String?
    let price: Double?

    private enum CodingKeys: String, CodingKey {
        case name
        case price
        case modificationName
        case modificationPrice
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name)
            ?? container.decodeIfPresent(String.self, forKey: .modificationName)
        price = try container.decodeIfPresent(Double.self, forKey: .price)
            ?? container.decodeIfPresent(Double.self, forKey: .modificationPrice)
    }
}

struct CartCount: Decodable {
    let count: Int
}

