//
//  MapCoordinator.swift
//  qahvazor-client
//
//  Created by Alphazet on 23/12/24.
//

import UIKit

final class MapCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = MapViewController()
        vc.tabBarItem = UITabBarItem(title: "map".localized, image: UIImage(systemName: "mappin.and.ellipse.circle"), selectedImage: UIImage(systemName: "mappin.and.ellipse.circle.fill"))
        vc.tabBarItem.tag = AppTab.map.rawValue
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func pushToShopDetail(id: Int, name: String?, distance: Double? = nil) {
        let vc = ShopDetailViewController()
        vc.shopId = id
        vc.distance = distance
        let mainCoordinator = MainCoordinator(navigationController: navigationController)
        vc.coordinator = mainCoordinator
        vc.navigationItem.title = name
        navigationController.pushViewController(vc, animated: true)
    }
}
