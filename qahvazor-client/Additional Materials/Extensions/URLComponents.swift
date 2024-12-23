//
//  URLComponents.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import Foundation

extension URLComponents {
    // MARK: - QueryItems
    mutating func setQueryParameters(_ parameters: [String: Any]?) {
        if let parameters = parameters, !parameters.isEmpty {
            queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                queryItems!.append(queryItem)
            }
        }
    }
}

extension URL {
    public var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return nil }
        guard let queryItems = components.queryItems else { return nil }
        
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}
