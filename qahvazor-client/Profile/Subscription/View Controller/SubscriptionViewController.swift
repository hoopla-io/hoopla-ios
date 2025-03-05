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
    var amount: Double?
    
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
    
    func didFinishFetchBought(statusCode: Int) {
        if statusCode == StatusCode.success200.rawValue {
            showSuccessAlert(message: "successBuySubscription".localized)
            navigationController?.popViewController(animated: true)
        } else {
            coordinator?.pushToPaymentVC(amount: amount)
        }
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
    
    func showBuyAlert(id: Int) {
        let alert = UIAlertController(title: "infoBuySubscription".localized, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "yes".localized, style: UIAlertAction.Style.default, handler: { [weak self] _ in
            self?.viewModel.subscriptionBuy(id: id)
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized, style: UIAlertAction.Style.cancel))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
