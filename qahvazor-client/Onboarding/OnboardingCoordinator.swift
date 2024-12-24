//
//  OnboardingCoordinator.swift
//  qahvazor-client
//
//  Created by Alphazet on 24/12/24.
//

import UIKit

final class OnboardingCoordinator: Coordinator {
    
    internal var childCoordinators = [Coordinator]()
    internal var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = LanguageViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func pushToFullOnBoardingVC() {
        let vc = FullOnboardingViewController()
        vc.coordinator = self
        vc.onboarding = .first
        navigationController.pushViewController(vc, animated: false)
    }
    
    func pushToInterestVC() {
        let vc = InterestViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}

