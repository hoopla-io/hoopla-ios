//
//  Modification.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 01/11/25.
//

import Foundation

struct ConfirmDrink: Codable {
    let modifications: Modifications?
    let modifierGroups: [ModifierGroups]?
}

struct ModifierGroups: Codable {
    let key: String?
    let maxSelect: Int?
    let minSelect: Int?
    let name: String?
    let options: [Modification]?
}

struct Modifications: Codable {
    let size: [Modification]?
    let sugar: [Modification]?
    let milk: [Modification]?
    let syrup: [Modification]?
}

struct Modification: Codable {
    let modificationGroupId: String?
    let modificationId: String?
    let modificationKey: String?
    let modificationName: String?
    let modificationPrice: Double?
}
