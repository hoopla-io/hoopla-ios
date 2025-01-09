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
        viewModel.getFilialsList(partnerId: partnerId)
    }
    
}
// MARK: - Networking
extension ShopsListViewController: ShopsListViewModelProtocol {
    func didFinishFetch(data: [Shop]) {
        dataProvider?.items = data
    }
}

// MARK: - Other funcs
extension ShopsListViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        navigationItem.title = "filials".localized
        
        let dataProvider = ShopsListDataProvider(viewController: self)
        dataProvider.collectionView = view().collectionView
        self.dataProvider = dataProvider
    }
    
}

