//
//  HistoryCoordinator.swift
//  qahvazor-client
//
//  Created by Alphazet on 23/12/24.
//

import UIKit

final class HistoryCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = HistoryViewController()
        vc.tabBarItem = UITabBarItem(title: "orders".localized, image: UIImage(systemName: "clock.arrow.circlepath"), selectedImage: UIImage(systemName: "clock.arrow.circlepath"))
        vc.tabBarItem.tag = 2
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
}
