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
    let dateOfBirth: String?
    let dateOfBirthUnx: Int?
    let gender: String?
    
    var balanceInfo: String? {
        guard let balanceAmount = balance, let balanceCurrency = currency else {
            return nil
        }
        return "\(balanceAmount.formattedWithSeparator) \(balanceCurrency)"
    }
}

struct Cashbeck {
    static var balance: Double = 0.0
}

struct Purchase {
    static var isPurchased: Bool = false
}
