//
//  PaymentViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 05/03/25.
//

import UIKit
import SkeletonView

class PaymentViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = PaymentView

    // MARK: - Services
    internal var customSpinnerView = CustomSpinnerView()
    internal var isLoading = false
    internal var coordinator: Coordinator?
    private let viewModel = PaymentViewModel()
    private let profileViewModel = ProfileViewModel()
    
    // MARK: - Data Providers
    private var dataProvider: PaymentDataProvider?

    // MARK: - Attributes
    var amount: Double?
    
    // MARK: - Actions
    @objc func appBecomeActive() {
        removeObserver()
        profileViewModel.getMe()
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
        viewModel.getListPayment()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view().collectionView.collectionViewLayout.invalidateLayout()
    }
    
    deinit {
        removeObserver()
    }
}

// MARK: - Networking
extension PaymentViewController: PaymentViewModelProtocol {
    func didFinishFetch(data: [PaymentService]) {
        view().collectionView.checkEmpty(items: data)
        dataProvider?.items = data
    }
    
    func didFinishFetch(data: PaymentCheckout) {
        guard let checkoutUrl = data.checkoutUrl else { return }
        setupObserver()
        openURL(urlString: checkoutUrl)
    }
}
// MARK: - Networking
extension PaymentViewController: ProfileViewModelProtocol {
    func didFinishFetch(data: Account) {
        guard data.balance ?? 0 != UserDefaults.standard.getBalance() else {
            return
        }
        showSuccessAlert(message: "success".localized)
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Other funcs
extension PaymentViewController {
    private func appearanceSettings() {
        navigationItem.title = "choosePayment".localized
        
        viewModel.delegate = self
        profileViewModel.delegate = self
        
        let dataProvider = PaymentDataProvider(viewController: self)
        dataProvider.collectionView = view().collectionView
        self.dataProvider = dataProvider
    }
    
    func itemSelected(serviceId: Int) {
        if let amount {
            viewModel.topUp(serviceId: serviceId, amount: String(amount))
        } else {
            showAlertWithTextField(title: "payment".localized, message: "enterAmount".localized) { text in
                guard let amount = text, !amount.isEmpty else { return }
                self.viewModel.topUp(serviceId: serviceId, amount: amount)
            }
        }
    }
    
    private func setupObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func removeObserver() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

