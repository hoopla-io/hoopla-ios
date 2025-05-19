//
//  LocationManager.swift
//  qahvazor-client
//
//  Created by Alphazet on 15/01/25.
//

import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var locationAuthorizationCallback: ((CLAuthorizationStatus) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    func requestLocationAuthorization(completion: @escaping (CLAuthorizationStatus) -> Void) {
        locationAuthorizationCallback = completion
    }

    func requestLocationPermission() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            // Request permission
            locationManager.requestWhenInUseAuthorization() // or requestAlwaysAuthorization()
        case .restricted, .denied:
            // Handle restricted or denied status (e.g., show an alert)
            print("Location permission restricted or denied.")
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission already granted
            locationManager.requestLocation()
            print("Location permission already granted.")
        @unknown default:
            print("Unknown location permission status.")
        }
        locationAuthorizationCallback?(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("User's location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            Coordinate.setCoordinate(coordinate: location.coordinate)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("Not determined")
        case .restricted:
            print("Restricted")
        case .denied:
            print("Denied")
        case .authorizedWhenInUse, .authorizedAlways:
            // Permission already granted
            locationManager.requestLocation()
        @unknown default:
            print("Unknown status")
        }
        locationAuthorizationCallback?(manager.authorizationStatus)
    }
}

