//
//  Account.swift
//  qahvazor-client
//
//  Created by Alphazet on 09/01/25.
//

import Foundation

struct Account: Codable {
    let userId: Int?
    let name: String?
    let phoneNumber: String?
    let balance: Double?
    let currency: String?
    let subscription: Subscription?
    
    var balanceInfo: String? {
        guard let balanceAmount = balance, let balanceCurrency = currency else {
            return nil
        }
        return "\(balanceAmount.formattedWithSeparator) \(balanceCurrency)"
    }
}
