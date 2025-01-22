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
    let distance: Double?
    let location: Location?
    let phoneNumbers: [PhoneNumber]?
    let pictureUrl: String?
    let pictures: [Pictures]?
    let workingHours: [WorkHour]?
    let urls: [SocialMedia]?
    let drinks: [Drinks]?
    let modules: [Module]?
}

struct Location: Codable {
    let lat: Double?
    let lng: Double?
}

struct PhoneNumber: Codable {
    let phoneNumber: String?
}

struct Pictures: Codable {
    let pictureUrl: String?
}

struct WorkHour: Codable {
    let closeAt: String?
    let openAt: String?
    let weekDay: String?
}

struct Module: Codable {
    let colour: String?
    let moduleId: Int?
    let name: String?
}

