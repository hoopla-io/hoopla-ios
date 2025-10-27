//
//  Notification.swift
//  itv-new
//
//  Created by Jakhongir Nematov on 07/01/22.
//

import Foundation

struct NewsNotification: Codable {
    let notificationId: Int?
    let notificationTitle: String?
    let notificationDescription: String?
    let notificationText: String?
    let shareUrl: String?
    let countReads: Int?
    let createdAt: String?
//    var params: Params?
    let files: Files?
    let url: String?
    let unreadCount: Int?
}
