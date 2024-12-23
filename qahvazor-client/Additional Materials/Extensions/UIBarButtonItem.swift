//
//  UIBarButtonItem.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import Foundation
import UIKit

extension UIBarButtonItem {
    class func back(_ target: AnyObject) -> UIBarButtonItem {
        return UIBarButtonItem(title: "", style: .plain, target: target, action: nil)
    }
}

