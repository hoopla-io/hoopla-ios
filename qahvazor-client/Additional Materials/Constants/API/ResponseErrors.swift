//
//  ResponseErrors.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import Foundation

enum Result<T> {
    case Success(T)
    case Error(APIError, String? = nil)
}

enum APIError: Error {
    case requestFailed
    case invalidData
    case responseUnsuccessful
    case serverError
    case notAuthorized
    case fromMessage
    case notEnoughBalance
}
