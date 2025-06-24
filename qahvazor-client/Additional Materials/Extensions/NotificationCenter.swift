//
//  NotificationCenter.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import Foundation

enum UserInfoName: String {
    case subscriptions
    case shopId
}

extension Notification.Name {
    static let timeshiftGuideChanged = Notification.Name("timeshiftGuideChanged")
    static let universalLink = Notification.Name("universalLink")
    
    func post(object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: self, object: object, userInfo: userInfo)
    }
    
    @discardableResult
    func onPost(object: Any? = nil, queue: OperationQueue? = nil, using: @escaping (Notification) -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(forName: self, object: object, queue: queue, using: using)
    }
}
