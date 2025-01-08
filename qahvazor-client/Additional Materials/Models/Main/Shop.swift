//
//  Shop.swift
//  qahvazor-client
//
//  Created by Alphazet on 07/01/25.
//

import Foundation

struct Shop: Codable {
    let shopId: Int?
    let name: String?
    let location: Location?
    let phoneNumbers: [PhoneNumber]?
    let pictureUrl: String?
}

struct Location: Codable {
    let lat: Double?
    let lng: Double?
}

struct PhoneNumber: Codable {
    let phoneNumber: String?
}
