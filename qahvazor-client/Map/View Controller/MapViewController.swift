//
//  MapViewController.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 27/10/25.
//

import UIKit
import MapKit
import CoreLocation

final class MapViewController: UIViewController {
    var coordinator: MapCoordinator?
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let regionMeters: CLLocationDistance = 1_000

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Map setup
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.pointOfInterestFilter = .includingAll

        // Register annotation view (marker style + clustering)
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)

        requestLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if mapView.annotations.count < 2 {
            addPins()
        }
        
        guard Purchase.isPurchased else { return }
        Purchase.isPurchased = false
        tabBarController?.selectedIndex = 2
    }

    private func requestLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }

    private func centerOnUser(_ location: CLLocation) {
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: regionMeters,
                                        longitudinalMeters: regionMeters)
        mapView.setRegion(region, animated: true)
    }

    private func addPins() {
        for i in ShopDataCache.shops {
            let location = CLLocationCoordinate2D(latitude: i.location?.lat ?? 0, longitude: i.location?.lng ?? 0)
            let ann = MKPointAnnotation()
            ann.title = i.name
            ann.subtitle = i.distance?.formatDistance()
            ann.coordinate = location
            mapView.addAnnotation(ann)
        }
    }

}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        centerOnUser(loc)
        manager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error)
    }
}

extension MapViewController: MKMapViewDelegate {
    // Customize marker + clustering
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation) as! MKMarkerAnnotationView
        view.canShowCallout = true
        view.clusteringIdentifier = "place"
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return view
    }

    // Tap on callout → route in Apple Maps
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let ann = view.annotation else { return }
        let item = ShopDataCache.shops.first(where: { $0.name == ann.title ?? "" })
        coordinator?.pushToShopDetail(id: item?.shopId ?? 0, name: item?.name, distance: item?.distance)
    }
}
