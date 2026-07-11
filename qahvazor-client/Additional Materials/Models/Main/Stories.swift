//
//  Stories.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 16/05/26.
//

import Foundation

struct Stories: Codable {
    let id: Int?
    let title: String?
    let coverImageUrl: String?
    let isSeen: Bool?
    let items: [StoryDetail]?
}

struct StoryDetail: Codable {
    let id: Int?
    let title: String?
    let imageUrl: String?
    let description: String?
    let linkType: String?
    let linkValue: String?
    let duration: Int?
}

