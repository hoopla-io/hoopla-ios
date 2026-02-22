//
//  Checkout.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 21/02/26.
//

import Foundation

struct Checkout: Decodable {
    let orderId: Int?
    let checkoutUrl: String?
    let status: String?
}
