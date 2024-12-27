//
//  UINavigationBar.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit

extension UINavigationBar {
    
    func setup() {
        tintColor = UIColor.label
        titleTextAttributes = [.foregroundColor: UIColor.label]
        largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .highlighted)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
    }
    
    func clear() {
        shadowImage = UIImage()
        setBackgroundImage(UIImage(), for: .default)
    }
    
    func reset() {
        shadowImage = nil
        setBackgroundImage(nil, for: .default)
    }
}


