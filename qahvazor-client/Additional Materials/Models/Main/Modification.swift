//
//  Modification.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 01/11/25.
//

import Foundation

struct ConfirmDrink: Codable {
    let cashbackPercent: Int?
    let modifierGroups: [ModifierGroups]?
}

struct ModifierGroups: Codable {
    let key: String?
    let maxSelect: Int?
    let minSelect: Int?
    let name: String?
    let options: [Modification]?
}

struct Modification: Codable {
    let modificationGroupId: String?
    let modificationId: String?
    let modificationKey: String?
    let modificationName: String?
    let modificationPrice: Double?
}
