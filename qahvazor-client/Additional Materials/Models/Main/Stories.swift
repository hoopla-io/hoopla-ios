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

    private enum CodingKeys: String, CodingKey {
        case id, title, imageUrl, description, linkType, linkValue, duration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        linkType = try container.decodeIfPresent(String.self, forKey: .linkType)
        duration = try container.decodeIfPresent(Int.self, forKey: .duration)

        if let stringValue = try? container.decode(String.self, forKey: .linkValue) {
            linkValue = stringValue
        } else if let intValue = try? container.decode(Int.self, forKey: .linkValue) {
            linkValue = String(intValue)
        } else {
            linkValue = nil
        }
    }
}

enum StoryLinkAction {
    case partner(Int)
    case url(URL)
    case shop(Int)
}

extension StoryDetail {
    var linkAction: StoryLinkAction? {
        guard let linkType = linkType?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
              let linkValue = linkValue?.trimmingCharacters(in: .whitespacesAndNewlines),
              !linkValue.isEmpty else { return nil }

        switch linkType {
        case "partner":
            guard let partnerId = Int(linkValue) else { return nil }
            return .partner(partnerId)
        case "url":
            guard let url = URL(string: linkValue),
                  let scheme = url.scheme?.lowercased(),
                  scheme == "http" || scheme == "https" else { return nil }
            return .url(url)
        case "shop":
            guard let shopId = Int(linkValue) else { return nil }
            return .shop(shopId)
        default:
            return nil
        }
    }
}
