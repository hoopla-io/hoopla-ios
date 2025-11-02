//
//  Modification.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 01/11/25.
//

import Foundation

struct Modifications: Codable {
    let size: [Modification]?
    let sugar: [Modification]?
}

struct Modification: Codable {
    let modificationGroupId: String?
    let modificationId: String?
    let modificationKey: String?
    let modificationName: String?
    let modificationPrice: Double?
}
