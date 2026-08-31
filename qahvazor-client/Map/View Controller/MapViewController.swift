//
//  MapViewController.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 27/10/25.
//

import UIKit
import MapKit
import CoreLocation
import SDWebImage

final class MapViewController: UIViewController {
    var coordinator: MapCoordinator?
    private let mapView = MKMapView()
    private let shopPreviewView = ShopPreviewView()
    private let locationManager = CLLocationManager()
    private let regionMeters: CLLocationDistance = 1_000
    private var selectedShop: Shop?
    private var selectedShopAnnotation: ShopAnnotation?

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

        setupShopPreview()

        mapView.delegate = self
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.pointOfInterestFilter = .includingAll

        // Register annotation views
        mapView.register(ShopAnnotationView.self, forAnnotationViewWithReuseIdentifier: ShopAnnotationView.reuseIdentifier)
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
        tabBarController?.selectTab(.orders)
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
            let ann = ShopAnnotation(shop: i)
            mapView.addAnnotation(ann)
        }
    }

    private func setupShopPreview() {
        shopPreviewView.translatesAutoresizingMaskIntoConstraints = false
        shopPreviewView.isHidden = true
        shopPreviewView.alpha = 0
        view.addSubview(shopPreviewView)

        NSLayoutConstraint.activate([
            shopPreviewView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            shopPreviewView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            shopPreviewView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])

        shopPreviewView.onClose = { [weak self] in
            self?.dismissShopPreview()
        }
        shopPreviewView.onOrder = { [weak self] in
            guard let self, let shop = self.selectedShop else { return }
            self.coordinator?.pushToShopDetail(
                id: shop.shopId ?? 0,
                name: shop.name,
                distance: shop.distance
            )
        }
    }

    private func presentShopPreview(for shop: Shop) {
        selectedShop = shop
        shopPreviewView.configure(with: shop)

        if shopPreviewView.isHidden {
            shopPreviewView.isHidden = false
            shopPreviewView.transform = CGAffineTransform(translationX: 0, y: 24)
        }

        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0.4,
            options: [.curveEaseOut, .beginFromCurrentState]
        ) {
            self.shopPreviewView.alpha = 1
            self.shopPreviewView.transform = .identity
        }
    }

    private func dismissShopPreview(deselectAnnotation: Bool = true) {
        updateMarkerSelection(selectedView: nil)
        selectedShop = nil
        selectedShopAnnotation = nil

        if deselectAnnotation, let annotation = mapView.selectedAnnotations.first {
            mapView.deselectAnnotation(annotation, animated: true)
        }

        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.curveEaseIn, .beginFromCurrentState]
        ) {
            self.shopPreviewView.alpha = 0
            self.shopPreviewView.transform = CGAffineTransform(translationX: 0, y: 18)
        } completion: { _ in
            guard self.shopPreviewView.alpha == 0 else { return }
            self.shopPreviewView.isHidden = true
        }
    }

    private func updateMarkerSelection(selectedView: ShopAnnotationView?) {
        mapView.annotations.forEach { annotation in
            guard let markerView = mapView.view(for: annotation) as? ShopAnnotationView else { return }
            markerView.setSelectionAppearance(
                isSelected: markerView === selectedView,
                animated: true
            )
        }

        if let selectedView {
            selectedView.superview?.bringSubviewToFront(selectedView)
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

        if let cluster = annotation as? MKClusterAnnotation {
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier, for: cluster) as! MKMarkerAnnotationView
            view.canShowCallout = false
            view.glyphText = String(cluster.memberAnnotations.count)
            return view
        }

        let view = mapView.dequeueReusableAnnotationView(withIdentifier: ShopAnnotationView.reuseIdentifier, for: annotation) as! ShopAnnotationView
        view.canShowCallout = false
        view.clusteringIdentifier = "place"
        let isSelected = selectedShopAnnotation === annotation
        view.setSelectionAppearance(
            isSelected: isSelected,
            animated: false
        )
        return view
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? ShopAnnotation else {
            dismissShopPreview(deselectAnnotation: false)
            return
        }
        selectedShopAnnotation = annotation
        updateMarkerSelection(selectedView: view as? ShopAnnotationView)
        mapView.setCenter(annotation.coordinate, animated: true)
        presentShopPreview(for: annotation.shop)
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        guard let annotation = view.annotation as? ShopAnnotation,
              selectedShopAnnotation === annotation else { return }
        dismissShopPreview(deselectAnnotation: false)
    }
}
