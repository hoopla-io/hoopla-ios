//
//  SignIn.swift
//  qahvazor-client
//
//  Created by Alphazet on 25/12/24.
//

import Foundation

struct SignIn: Codable {
    let phoneNumber: String?
    let verificationType: String?
    let sessionId: String?
    let sessionExpiresAt: Int?
    let email: String?
    let credentialType: String?
}

struct Tokens: Codable {
    let accessToken: String?
    let refreshToken: String?
    let expireAt: Int?
    let accountNumber: Int?
}

