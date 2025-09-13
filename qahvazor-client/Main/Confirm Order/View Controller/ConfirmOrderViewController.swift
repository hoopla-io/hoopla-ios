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
    var dataProvider: OnsDataProvider?
    
    // MARK: - Attributes
    var drinkData: Drinks? {
        didSet {
            navigationItem.title = "\(drinkData?.name ?? "")"
            view().drinkLabel.text = "\(drinkData?.name ?? "")"
            if let imageUrl = drinkData?.pictureUrl {
                view().imageView.setImage(with: imageUrl)
            }
            view().priceLabel.text = drinkData?.productPrice?.formattedWithCurrency
        }
    }
    var shopData: Shop? {
        didSet {
            view().shopLabel.text = shopData?.name
            guard let shopId = shopData?.id, let drinkId = drinkData?.id else { return }
            viewModel.validateOrder(drinkId: drinkId, shopId: shopId)
        }
    }
    var selectedOns: AddOns?
    
    //MARK: - Actions
    @IBAction func confirmOrderAction(_ sender: Any) {
        guard let shopId = shopData?.id, let drinkId = drinkData?.id else { return }
        viewModel.createOrder(drinkId: drinkId, shopId: shopId, addOnId: selectedOns?.vendorAddOnId)
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
        if statusCode == StatusCode.notEnoughBalance.rawValue {
            coordinator.pushToPaymentVC(amount: self.drinkData?.productPrice)
        } else if statusCode == StatusCode.success200.rawValue {
            showSuccessAlert(message: "success".localized)
            tabBarController?.selectedIndex = 1
            navigationController?.popToRootViewController(animated: false)
        }
    }
    
    func didFinishFetch(data: ConfirmDrink?) {
        guard let ons = data?.addOns else { return }
        view().onsStackView.isHidden = ons.isEmpty
        selectedOns = ons.first
        dataProvider?.items = ons
        
        view().collectionHeightConstraint.constant = dataProvider?.collectionView.collectionViewLayout.collectionViewContentSize.height ?? 0
        UIView.animate(withDuration: 0.3) {
            self.dataProvider?.collectionView.layoutIfNeeded()
        }
    }
}
// MARK: - Other funcs
extension ConfirmOrderViewController {
    private func appearanceSettings() {
        navigationItem.largeTitleDisplayMode = .never
        viewModel.delegate = self
        
        let dataProvider = OnsDataProvider(viewController: self)
        dataProvider.collectionView = view().collectionView
        self.dataProvider = dataProvider
    }
}

