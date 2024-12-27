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
    var dataProvide: ShopsListDataProvider?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        
    }
    
}
// MARK: - Networking
extension ShopsListViewController: ShopsListViewModelProtocol {
    func didFinishFetch(data: Company) {
        
    }
}

// MARK: - Other funcs
extension ShopsListViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        navigationItem.title = "filials".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let dataProvider = ShopsListDataProvider(viewController: self)
        dataProvider.collectionView = view().collectionView
        self.dataProvide = dataProvider
    }
}

