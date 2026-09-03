//
//  Headers.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit

struct ClientDeviceInfo: Sendable {
    let deviceName: String
    let platform: String
    let deviceId: String
    let appVersion: String
    
    @MainActor
    static var current: ClientDeviceInfo {
        ClientDeviceInfo(
            deviceName: UIDevice.current.name,
            platform: UIDevice.current.systemName.lowercased(),
            deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "",
            appVersion: Bundle.main.releaseVersionNumber ?? ""
        )
    }
}

enum Headers: String {
    case applicationJson = "application/json"
    case contentType = "Content-Type"
    case apple = "Apple"
    case phone = "mobile"
    case pad = "tablet"
    case AUTHORIZATION = "Authorization"
    case deviceName = "X-Device-Name"
    case platform = "X-Platform"
    case deviceId = "X-Device-Id"
    case appVersion = "X-App-Version"
    case language = "X-App-Language"
}
