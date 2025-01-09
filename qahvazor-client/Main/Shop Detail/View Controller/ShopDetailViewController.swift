//
//  ShopDetailViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 09/01/25.
//

import UIKit

class ShopDetailViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = ShopDetailView

    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    var coordinator: MainCoordinator?
    let viewModel = ShopDetailViewModel()
    
    // MARK: - Attributes
    var pictureDataProvider: PhotoDataProvider?
    var workTimeDataProvider: WorkTimeDataProvider?
    var shopId: Int?
    var data: Shop?
    
    // MARK: - Actions
    @IBAction func addressButtonAction(_ sender: Any) {
        guard let lat = data?.location?.lat, let lng = data?.location?.lng else { return }
        openMaps(latitude: lat, longitude: lng, title: "maps".localized)
    }

    @IBAction func callButtonAction(_ sender: Any) {
        guard let phoneNumbers = data?.phoneNumbers else { return }
        if phoneNumbers.count == 1 {
            self.callAction(phoneNumber: phoneNumbers.first?.phoneNumber)
        } else {
            showCallPhoneActionSheet(items: phoneNumbers) { phoneNumber in
                self.callAction(phoneNumber: phoneNumber)
            }
        }
    }
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        
        guard let shopId else { return }
        viewModel.getShopInfo(shopId: shopId)
    }
    
}
// MARK: - Networking
extension ShopDetailViewController: ShopDetailViewModelProtocol {
    func didFinishFetch(data: Shop) {
        self.data = data
        if let pictures = data.pictures {
            pictureDataProvider?.items = pictures
            view().pageControll.numberOfPages = pictures.count
        }
        if let workingHours = data.workingHours {
            workTimeDataProvider?.items = workingHours
        }
    }
}

// MARK: - Other funcs
extension ShopDetailViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        
        let pictureDataProvider = PhotoDataProvider(viewController: self)
        pictureDataProvider.collectionView = view().collectionView
        self.pictureDataProvider = pictureDataProvider
        
        let workTimeDataProvider = WorkTimeDataProvider()
        workTimeDataProvider.tableView = view().tableView
        self.workTimeDataProvider = workTimeDataProvider
    }
    
    func callAction(phoneNumber: String?) {
        guard let phoneNumber else { return }
        if let url = URL(string: "tel://+\(phoneNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("Phone call not supported on this device")
            }
        }
    }
    
    func openMaps(latitude: Double, longitude: Double, title: String?) {
        let application = UIApplication.shared
        let coordinate = "\(latitude),\(longitude)"
        let handlers = [
            ("Yandex Maps", "yandexmaps://maps.yandex.ru/?pt=\(longitude),\(latitude)"),
            ("Apple Maps", "http://maps.apple.com/?q=&ll=\(coordinate)"),
            ("Yandex Navigator", "yandexnavi://build_route_on_map?lat_to=\(latitude)&lon_to=\(longitude)"),
            ("2gis Map", "dgis://2gis.ru/routeSearch/rsType/car/to/\(longitude),\(latitude)")
        ]
        
            .compactMap { (name, address) in URL(string: address).map { (name, $0) } }
            .filter { (_, url) in application.canOpenURL(url) }

        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet)
            handlers.forEach { (name, url) in
                alert.addAction(UIAlertAction(title: name, style: .default) { _ in
                    application.open(url, options: [:])
                })
            }
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
    }
    
    func didScrollPicture(offset: CGFloat) {
        view().pageControll.currentPage = Int(offset)
    }
}


