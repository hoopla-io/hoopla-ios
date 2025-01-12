//
//  SubscriptionViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 11/01/25.
//

import UIKit

class SubscriptionViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = SubscriptionView

    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    var coordinator: ProfileCoordinator?
    let viewModel = SubscriptionViewModel()
    
    // MARK: - Attributes
    var dataProvider: SubscriptionDataProvider?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        viewModel.getList()
    }
    
}
// MARK: - Networking
extension SubscriptionViewController: SubscriptionViewModelProtocol {
    func didFinishFetch(data: [Subscription]) {
        dataProvider?.items = data
    }
}

// MARK: - Other funcs
extension SubscriptionViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        navigationItem.title = "subscriptions".localized
        
        let dataProvider = SubscriptionDataProvider(viewController: self)
        dataProvider.collectionView = view().collectionView
        self.dataProvider = dataProvider
        
    }
}
