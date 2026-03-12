//
//  AppUtility.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit

struct AppUtility {
    
    
    static func rotateTo(_ rotateOrientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
    
    
}
