//
//  Promocode.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 08/07/26.
//

import Foundation

struct PromocodePreview: Decodable {
    let valid: Bool?
    let code: String?
    let discountType: String?
    let discountValue: Double?
    let discountAmount: Double?
    let subtotal: Double?
    let total: Double?
}
