//
//  LaunchScreenViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 24/12/24.
//

import UIKit

class LaunchScreenViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = LaunchScreenView

    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        next()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}

// MARK: - Other funcs
extension LaunchScreenViewController {
    
    private func showOnboarding() {
        guard let navigationController = navigationController else { return }
        let onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)
        onboardingCoordinator.start()
    }
    
    private func next() {
        UserDefaults.standard.isNotFirstLaunch() ? resetTabBar() : showOnboarding()
    }
}

