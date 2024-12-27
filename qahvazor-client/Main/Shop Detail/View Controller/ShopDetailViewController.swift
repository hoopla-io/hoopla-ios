//
//  ShopDetailViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 27/12/24.
//

import UIKit

class ShopDetailViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = ShopDetailView

    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    var coordinator: MainCoordinator?
    let viewModel = ShopsListViewModel()
    
    // MARK: - Attributes
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.clear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.reset()
    }
    
}
// MARK: - Networking
extension ShopDetailViewController: ShopsListViewModelProtocol {
    func didFinishFetch(data: Company) {
        
    }
}

// MARK: - Other funcs
extension ShopDetailViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        
    }
}

