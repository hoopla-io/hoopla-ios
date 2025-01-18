//
//  Coordinate.swift
//  qahvazor-client
//
//  Created by Alphazet on 15/01/25.
//

import CoreLocation

struct Coordinate {
    static var latitude: Double {
        return  UserDefaults.standard.getLatitude() == 0.0 ? 41.311326 : UserDefaults.standard.getLatitude()
    }
    static var longitude: Double {
        return  UserDefaults.standard.getLongitude() == 0.0 ? 69.279681 : UserDefaults.standard.getLongitude()
    }
    
    static func setCoordinate(coordinate: CLLocationCoordinate2D) {
        UserDefaults.standard.saveLatitude(coordinate.latitude)
        UserDefaults.standard.saveLongitude(coordinate.longitude)
    }
}
