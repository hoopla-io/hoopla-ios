//
//  SKStoreReviewController.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import StoreKit
import UIKit

extension SKStoreReviewController {
    public static func requestReviewInCurrentScene() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if #available(iOS 14.0, *) {
                requestReview(in: scene)
            } else {
                SKStoreReviewController.requestReview()
            }
        }
    }
}

