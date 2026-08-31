//
//  Checkout.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 21/02/26.
//

import Foundation

struct Checkout: Decodable {
    let orderId: Int?
    let amount: Double?
    let checkoutUrl: String?
    let deeplink: String?
    let shortLink: String?
    let expiresAt: String?
    let status: String?
}
