//
//  Subscription.swift
//  qahvazor-client
//
//  Created by Alphazet on 11/01/25.
//

import Foundation

struct Subscription: Codable {
    let id: Int?
    let name: String?
    let price: Double?
    let currency: String?
    let days: Int?
    let features: [SubscriptionFeature]?
    let endDateUnix: Int?
    
    var descriptionPrice: String? {
        guard let days = days, let price = price, let currency = currency else {
            return nil
        }
        return "\(days) \("days".localized) - \(price.formattedWithSeparator) \(currency)"
    }
}

struct SubscriptionFeature: Codable {
    let id: Int?
    let feature: String?
}
