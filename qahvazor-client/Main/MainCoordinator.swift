//
//  MainCoordinator.swift
//  qahvazor-client
//
//  Created by Alphazet on 23/12/24.
//

import UIKit
import SwiftMessages

final class MainCoordinator: Coordinator {
    
    internal var childCoordinators = [Coordinator]()
    internal var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = MainViewController()
        vc.tabBarItem = UITabBarItem(title: "home".localized, image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        vc.tabBarItem.tag = 0
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func startSearch() {
        let vc = SearchViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func pushToShopDetail(id: Int, name: String?, distance: Double? = nil) {
        let vc = ShopDetailViewController()
        vc.shopId = id
        vc.distance = distance
        vc.coordinator = self
        vc.navigationItem.title = name
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToConfirmOrderVC(viewController: UIViewController, data: Drinks, shop: Shop?) {
        let vc = ConfirmOrderViewController()
        vc.data = data
        vc.shopData = shop
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToSubscriptionVC() {
        let vc = SubscriptionViewController()
        let profileCoordinator = ProfileCoordinator(navigationController: navigationController)
        vc.coordinator = profileCoordinator
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToScannerVC(viewController: UIViewController) {
        let vc = ScannerViewController()
        if let viewController = viewController as? MainViewController {
            vc.delegate = viewController
        }
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
}
