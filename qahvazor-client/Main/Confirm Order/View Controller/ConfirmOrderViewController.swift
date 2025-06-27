//
//  ConfirmOrderViewController.swift
//  qahvazor-client
//
//  Created by Alphazet on 24/06/25.
//

import UIKit

class ConfirmOrderViewController: UIViewController, ViewSpecificController, AlertViewController {
    // MARK: - Root View
    typealias RootView = ConfirmOrderView
    
    // MARK: - Services
    var coordinator: Coordinator?
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    let viewModel = ConfirmOrderViewModel()
    
    //MARK: - Actions
    @IBAction func confirmOrderAction(_ sender: Any) {
        guard let shopId = shopData?.id, let drinkId = data?.id else { return }
        viewModel.createOrder(drinkId: drinkId, shopId: shopId)
    }
    
    // MARK: - Attributes
    var data: Drinks? {
        didSet {
            navigationItem.title = "\(data?.name ?? "")"
            view().drinkLabel.text = "\(data?.name ?? "")"
            view().dateLabel.text = DateFormatter.string(formatter: .orderedDate)
        }
    }
    var shopData: Shop? {
        didSet {
            view().shopLabel.text = shopData?.name
        }
    }
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
    
}

// MARK: - Networking
extension ConfirmOrderViewController: ConfirmOrderViewModelProtocol {
    func didFinishFetch(data: WorkHour?, statusCode: Int) {
        guard let coordinator = coordinator as? MainCoordinator else { return }
        if statusCode == StatusCode.needSubscription.rawValue {
            coordinator.pushToSubscriptionVC()
        } else if statusCode == StatusCode.success200.rawValue {
            showSuccessAlert(message: "success".localized)
            tabBarController?.selectedIndex = 1
            navigationController?.popToRootViewController(animated: false)
        }
    }
}
// MARK: - Other funcs
extension ConfirmOrderViewController {
    private func appearanceSettings() {
        navigationItem.largeTitleDisplayMode = .never
        viewModel.delegate = self
    }
}

