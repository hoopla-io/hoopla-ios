//
//  MainCoordinator.swift
//  qahvazor-client
//
//  Created by Alphazet on 23/12/24.
//

import UIKit

final class MainCoordinator: Coordinator {
    
    internal var childCoordinators = [Coordinator]()
    internal var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = MainViewController()
        vc.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        vc.tabBarItem.tag = 0
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func pushToShopsListVC(id: Int?) {
        let vc = ShopsListViewController()
        vc.partnerId = id
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToShopsDetailVC(id: Int?) {
        let vc = ShopDetailViewController()
        vc.partnerId = id
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
