//
//  Categories.swift
//  qahvazor-client
//
//  Created by iOS on 09/04/26.
//

import Foundation

struct Categories: Codable {
    let id: Int?
    let name: String?
    let drinks: [Drinks]?
}
