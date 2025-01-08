//
//  SignIn.swift
//  qahvazor-client
//
//  Created by Alphazet on 25/12/24.
//

import Foundation

struct Auth: Codable {
    let phoneNumber: String?
    let sessionId: String?
    let sessionExpiresAt: Int?
}

struct Tokens: Codable {
    let accessToken: String?
    let refreshToken: String?
    let expireAt: Int?
}

struct SignIn: Codable {
    let jwt: Tokens?
    let userId: Int?
}
