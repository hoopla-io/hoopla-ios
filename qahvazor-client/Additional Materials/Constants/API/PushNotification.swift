//
//  PushNotification.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import Foundation

enum PushNotificationType: String {
    case id = "notificationId"
    case notification = "notification"
    case content = "content"
    case type = "notificationType"
}

struct PushNotification {
    static var id: String?
    static var type: String?
    
    static func clear() {
        id = nil
        type = nil
    }
}


