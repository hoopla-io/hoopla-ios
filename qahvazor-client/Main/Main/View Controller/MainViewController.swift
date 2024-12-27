//
//  MainViewController.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit

class MainViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = MainView

    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    var coordinator: MainCoordinator?
    let viewModel = MainViewModel()
    
    // MARK: - Attributes
    var dataProvide: MainDataProvider?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        
    }
    
}
// MARK: - Networking
extension MainViewController: MainViewModelProtocol {
    func didFinishFetch(data: Company) {
        
    }
}

// MARK: - Other funcs
extension MainViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        navigationItem.title = "coffeeShops".localized
        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.largeTitleDisplayMode = .automatic
        
        let dataProvider = MainDataProvider(viewController: self)
        dataProvider.collectionView = view().collectionView
        self.dataProvide = dataProvider
    }
}

//MARK: - Scroll to up
extension MainViewController: TabBarReselectHandling {
    func handleReselect() {
//        view().scrollView.setContentOffset(CGPoint(x: 0, y: -90), animated: true)
    }
}

