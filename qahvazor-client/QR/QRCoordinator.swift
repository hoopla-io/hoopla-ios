//
//  QRCoordinator.swift
//  qahvazor-client
//
//  Created by Alphazet on 23/12/24.
//

import UIKit

final class QRCoordinator: Coordinator {
    
    internal var childCoordinators = [Coordinator]()
    internal var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    internal func start() {
        let vc = QRViewController()
        vc.tabBarItem = UITabBarItem(title: "QR", image: UIImage(systemName: "qrcode.viewfinder"), selectedImage: UIImage(systemName: "qrcode.viewfinder"))
        vc.tabBarItem.tag = 1
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
}
