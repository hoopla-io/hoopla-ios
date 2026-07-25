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
        view.canShowCallout = true
        view.clusteringIdentifier = "place"
        view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        return view
    }

    // Tap on callout → route in Apple Maps
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let item = (view.annotation as? ShopAnnotation)?.shop else { return }
        coordinator?.pushToShopDetail(id: item.shopId ?? 0, name: item.name, distance: item.distance)
    }
}

private final class ShopAnnotation: NSObject, MKAnnotation {
    let shop: Shop
    let coordinate: CLLocationCoordinate2D

    var title: String? {
        shop.name
    }

    var subtitle: String? {
        shop.distance?.formatDistance()
    }

    init(shop: Shop) {
        self.shop = shop
        self.coordinate = CLLocationCoordinate2D(latitude: shop.location?.lat ?? 0, longitude: shop.location?.lng ?? 0)
        super.init()
    }
}

private final class ShopAnnotationView: MKAnnotationView {
    static let reuseIdentifier = "ShopAnnotationView"

    private enum Layout {
        static let viewSize = CGSize(width: 44, height: 52)
        static let logoSize = CGSize(width: 36, height: 36)
        static let pointerSize = CGSize(width: 14, height: 14)
        static let logoInset: CGFloat = 4
    }

    private let containerView = UIView()
    private let pointerView = UIView()
    private let imageView = UIImageView()

    private static let placeholderImage = UIImage(named: "placeHolder") ?? UIImage(named: "placeholder") ?? UIImage()

    override var annotation: MKAnnotation? {
        didSet {
            configure()
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        configure()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = Self.placeholderImage
    }

    private func setupView() {
        bounds = CGRect(origin: .zero, size: Layout.viewSize)
        centerOffset = CGPoint(x: 0, y: -Layout.viewSize.height / 2)
        calloutOffset = CGPoint(x: 0, y: -4)

        pointerView.frame = CGRect(
            x: (Layout.viewSize.width - Layout.pointerSize.width) / 2,
            y: Layout.viewSize.height - Layout.pointerSize.height - 5,
            width: Layout.pointerSize.width,
            height: Layout.pointerSize.height
        )
        pointerView.backgroundColor = .systemBackground
        pointerView.transform = CGAffineTransform(rotationAngle: .pi / 4)

        containerView.frame = CGRect(x: 0, y: 0, width: Layout.viewSize.width, height: Layout.viewSize.width)
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = Layout.viewSize.width / 2
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.systemBackground.cgColor
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.18
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)

        imageView.frame = CGRect(
            x: Layout.logoInset,
            y: Layout.logoInset,
            width: Layout.logoSize.width,
            height: Layout.logoSize.height
        )
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Layout.logoSize.width / 2
        imageView.image = Self.placeholderImage

        containerView.addSubview(imageView)
        addSubview(pointerView)
        addSubview(containerView)
    }

    private func configure() {
        guard let shop = (annotation as? ShopAnnotation)?.shop else { return }

        guard let logoUrl = shop.logoUrl, let url = URL(string: logoUrl) else {
            imageView.image = Self.placeholderImage
            return
        }

        imageView.sd_setImage(with: url, placeholderImage: Self.placeholderImage)
    }
}
