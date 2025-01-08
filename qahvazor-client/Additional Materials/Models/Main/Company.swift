//
//  Company.swift
//  qahvazor-client
//
//  Created by Alphazet on 26/12/24.
//

import Foundation

struct Company: Codable {
    let id: Int?
    let name: String?
    let description: String?
    let logoUrl: String?
    let phoneNumbers: [PhoneNumber]?
    let urls: [SocialMedia]?
}

struct SocialMedia: Codable {
    let url: String?
    let urlType: String?
}
