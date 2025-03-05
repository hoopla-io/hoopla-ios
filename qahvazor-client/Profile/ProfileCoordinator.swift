//
//  ProfileCoordinator.swift
//  qahvazor-client
//
//  Created by Alphazet on 23/12/24.
//

import UIKit

final class ProfileCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = ProfileViewController()
        vc.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), selectedImage: UIImage(systemName: "person.crop.circle.fill"))
        vc.tabBarItem.tag = 2
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func pushToCodeConfirmVC(data: Auth? = nil) {
        let vc = CodeConfirmViewController()
        vc.data = data
        vc.coordinator = self
        vc.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToLanguageVC(viewController: UIViewController) {
        let vc = LanguageViewController()
        vc.fromSettings = true
        if let viewController = viewController as? ProfileViewController {
            vc.delegate = viewController
        }
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToSubscriptionVC() {
        let vc = SubscriptionViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToPaymentVC(amount: Double?) {
        let vc = PaymentViewController()
        vc.coordinator = self
        vc.amount = amount
        navigationController.pushViewController(vc, animated: true)
    }
}
