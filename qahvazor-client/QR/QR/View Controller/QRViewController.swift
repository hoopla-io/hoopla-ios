//
//  QRViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 10/01/25.
//

import UIKit
import ImageViewer_swift
import Haptica
import SkeletonView

class QRViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = QRView

    // MARK: - Services
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    var coordinator: QRCoordinator?
    let viewModel = QRViewModel()
    let profileViewModel = ProfileViewModel()
    
    // MARK: - Attributes
    var dataProvider: HistoryDataProvider?
    var data: QR? {
        didSet {
            guard let data else { return }
            if let value = data.qrCode {
                view().qrImageView.image = .generateQRCode(key: value)
                view().containerView.hideSkeleton()
                view().qrImageView.setupImageViewer(images: [view().qrImageView.image ?? UIImage()], options: [.theme(.dark), .closeIcon(.appImage(.closeCircle))], from: self)
            }
        }
    }
    var appDeactiveTime = Double()
    var durationInDeactive = Double()
    
    // MARK: - Actions
    @IBAction func authAction() {
        tabBarController?.selectedIndex = 2
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        if UserDefaults.standard.isAuthed() {
            viewModel.getQRCode()
            viewModel.getOrderHistoryList()
            profileViewModel.getMe()
            viewModel.getDrinksLimit()
        }
    }
    
}
// MARK: - Networking
extension QRViewController: QRViewModelProtocol {
    func didFinishFetch(data: QR) {
        self.data = data
    }
    
    func didFinishFetch(data: [OrderHistory]?) {
        if let data {
            dataProvider?.items = data
        } else {
            dataProvider?.items.removeAll()
        }
        view().tableView.checkEmpty(items: dataProvider?.items, type: .history)
    }
    
    func didFinishFetch(data: Limit?) {
        let used = data?.used ?? 0
        let aviailable = data?.available ?? 0
//        let limit = "dailyLimit".localized + " \(aviailable)"
//        view().limitButton.setTitle(limit, for: .normal)
        view().usedLabel.text = "\("used".localized): \(used)"
        view().availableLabel.text = "\("available".localized): \(aviailable)"
        if used == 0 {
            view().progress.progress = 0
        } else {
            view().progress.progress = Float(aviailable) / Float(used)
        }
    }
}
// MARK: - Networking
extension QRViewController: ProfileViewModelProtocol {
    func didFinishFetch(data: Account) {
        view().subscriptionLabel.text = data.subscription?.name
        view().phoneNumberLabel.text = data.phoneNumber?.displayPhone()
    }
}

// MARK: - Other funcs
extension QRViewController {
    private func appearanceSettings() {
        viewModel.delegate = self
        profileViewModel.delegate = self
        navigationItem.title = "QR".localized
        
        let dataProvider = HistoryDataProvider()
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
}
