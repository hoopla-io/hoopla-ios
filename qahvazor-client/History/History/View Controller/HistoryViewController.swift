//
//  HistoryViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 10/01/25.
//

import UIKit

class HistoryViewController: UIViewController, ViewSpecificController, @MainActor AlertViewController {
    // MARK: - Root View
    typealias RootView = HistoryView

    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    var coordinator: HistoryCoordinator?
    let viewModel = HistoryViewModel()
    
    // MARK: - Attributes
    var dataProvider: HistoryDataProvider?
    var appDeactiveTime = Double()
    var durationInDeactive = Double()
    
    // MARK: - Actions
    @IBAction func authAction() {
        tabBarController?.selectedIndex = 3
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.isAuthed() {
            viewModel.getOrderHistoryList()
        }
    }
    
}
// MARK: - Networking
extension HistoryViewController: HistoryViewModelProtocol {
    func didFinishFetch(data: [OrderHistory]?) {
        if let data {
            dataProvider?.items = data
        } else {
            dataProvider?.items.removeAll()
        }
        view().tableView.checkEmpty(items: dataProvider?.items, type: .history)
    }
}

// MARK: - Other funcs
extension HistoryViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        navigationItem.title = "history".localized
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let dataProvider = HistoryDataProvider(viewController: self)
        dataProvider.tableView = view().tableView
        self.dataProvider = dataProvider
        
        view().authContainerView.isHidden = UserDefaults.standard.isAuthed()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
        view().tableView.refreshControl = refreshControl
    }
    
    @objc func handleRefreshControl(sender: UIRefreshControl? = nil) {
        viewModel.getOrderHistoryList()
        
        DispatchQueue.main.async {
            sender?.endRefreshing()
        }
    }
    
    func openCheck(item: String) {
        openViaSafariVC(item, from: self)
    }
}
