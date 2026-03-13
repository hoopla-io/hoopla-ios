//
//  OrderStatus.swift
//  qahvazor-client
//
//  Created by iOS on 13/03/26.
//

import Foundation

enum OrderStatus: String {
    case pending
    case created
    case preparing
    case cancelled
    case completed
    case pending_payment
    case error
    case payment_expired
    case payment_failed
    case paid
}
