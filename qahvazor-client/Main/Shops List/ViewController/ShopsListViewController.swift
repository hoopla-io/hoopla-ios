//
//  ShopsListViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 26/12/24.
//

import UIKit

class ShopsListViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = ShopsListView

    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    var coordinator: MainCoordinator?
    let viewModel = ShopsListViewModel()
    
    // MARK: - Attributes
    var dataProvider: ShopsListDataProvider?
    var partnerId: Int?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        guard let partnerId else { return }
        viewModel.getPartnerInfo(id: partnerId)
        viewModel.getFilialsList(partnerId: partnerId)
    }
    
}
// MARK: - Networking
extension ShopsListViewController: ShopsListViewModelProtocol {
    func didFinishFetch(data: [Shop]) {
        dataProvider?.items = data
    }
    
    func didFinishFetch(data: Company) {
        navigationItem.title = data.name
    }
}

// MARK: - Other funcs
extension ShopsListViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let dataProvider = ShopsListDataProvider(viewController: self)
        dataProvider.collectionView = view().collectionView
        self.dataProvider = dataProvider
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
}

