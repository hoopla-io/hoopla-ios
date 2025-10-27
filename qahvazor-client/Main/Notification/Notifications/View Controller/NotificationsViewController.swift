//
//  NotificationsViewController.swift
//  itv-new
//
//  Created Admin NBU on 13/10/21.

import UIKit
import SkeletonView

class NotificationsViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = NotificationsView

    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading = false
    internal var coordinator: MainCoordinator?
    internal let viewModel = NotificationsViewModel()
    
    // MARK: - Data Providers
    private var dataProvider: NotificationsDataProvider?

    // MARK: - Attributes
    var totalItems = 0
    var currentPage = 1

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        viewModel.notificationsList()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view().collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - Networking
extension NotificationsViewController: NotificationsViewModelProtocol {
    func didFinishFetch(notifications: [NewsNotification], meta: Meta?) {
        view().collectionView.checkEmpty(items: notifications)
        dataProvider?.items += notifications
        guard let totalItems = meta?.totalItems else { return }
        self.totalItems = totalItems
    }
}

// MARK: - Other funcs
extension NotificationsViewController {
    private func appearanceSettings() {
        navigationItem.title = "notification".localized
        
        viewModel.delegate = self
        
        let dataProvider = NotificationsDataProvider(viewController: self)
        dataProvider.collectionView = view().collectionView
        self.dataProvider = dataProvider
    }
}
