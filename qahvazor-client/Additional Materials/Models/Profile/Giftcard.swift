//
//  Giftcard.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 11/07/26.
//

import Foundation

struct GiftcardRedemption: Decodable {
    let credited: Double
    let balance: Double
    let currency: String
}

struct GiftcardRedeemResponse: Decodable {
    let data: GiftcardRedemption?
}
