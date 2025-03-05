//
//  PaymentService.swift
//  qahvazor-client
//
//  Created by Alphazet on 05/03/25.
//

import Foundation

struct PaymentService: Codable {
    let name: String?
    let logoUrl: String?
    let id: Int?
}

struct PaymentCheckout: Codable {
    let checkoutUrl: String?
}
