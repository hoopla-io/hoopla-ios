//
//  JSONData.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import Foundation

struct JSONData<T: Decodable>: Decodable {
    let code: Int
    let message: String
    let language: String?
    let meta: Meta?
    
    let data: T?
}

struct Meta: Codable {
    let itemsPerPage: Int?
    let totalItems: Int?
    let currentPage: Int?
    let totalPages: Int?
}
