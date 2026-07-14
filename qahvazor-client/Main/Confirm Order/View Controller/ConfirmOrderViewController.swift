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
    var coordinator: MainCoordinator?
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    let viewModel = ConfirmOrderViewModel()
    
    // MARK: - Data Provider
    var modifierGroupDataProvider: ModifierGroupDataProvider?
    
    // MARK: - Attributes
    var drinkData: Drinks? {
        didSet {
            view().drinkLabel.text = "\(drinkData?.name ?? "")"
            if let imageUrl = drinkData?.pictureUrl {
                view().imageView.setImage(with: imageUrl)
            }
            productPrice = drinkData?.productPrice ?? 0.0
        }
    }
    var productPrice: Double = 0.0 {
        didSet {
            view().orderButton.setTitle(productPrice.formattedWithCurrency, for: .normal)
        }
    }
    var shopData: Shop? {
        didSet {
            view().shopLabel.text = shopData?.name
            guard let shopId = shopData?.id, let drinkId = drinkData?.id else { return }
            viewModel.validateOrder(drinkId: drinkId, shopId: shopId)
        }
    }
    var selectedModifiers = [Modification]()
    var cashbackPercent: Int?
    
    //MARK: - Actions
    @IBAction func confirmOrderAction(_ sender: Any) {
        if let validationMessage = modifierGroupDataProvider?.validationMessage() {
            showWarningAlert(message: validationMessage)
            return
        }

        coordinator?.pushToCheckoutVC(
            shopData: shopData,
            drinkData: drinkData,
            totalPrice: productPrice,
            comment: view().textView.text,
            modifiers: selectedModifiers,
            cashbackPercent: cashbackPercent
        )
    }
    
    func changePricingAction() {
        let basePrice = drinkData?.productPrice ?? 0.0

        let modifiersPrice = selectedModifiers.reduce(0.0) {
            $0 + ($1.modificationPrice ?? 0.0)
        }
        productPrice = basePrice + modifiersPrice
    }
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
    
}

// MARK: - Networking
extension ConfirmOrderViewController: ConfirmOrderViewModelProtocol {
    func didFinishFetch(data: [ModifierGroups]?, cashbackPercent: Int?) {
        let groups = data?.filter { $0.options?.isEmpty == false } ?? []
        view().collectionView.isHidden = groups.isEmpty
        if groups.isEmpty {
            view().collectionViewHeightConstraint.constant = 0
        }

        modifierGroupDataProvider?.groups = groups
        updateSelectedModifiers([])
        
        self.cashbackPercent = cashbackPercent
    }
}
// MARK: - Other funcs
extension ConfirmOrderViewController {
    private func appearanceSettings() {
        navigationItem.largeTitleDisplayMode = .never
        viewModel.delegate = self
        navigationItem.title = "orderSummary".localized

        let modifierGroupDataProvider = ModifierGroupDataProvider(viewController: self)
        modifierGroupDataProvider.collectionView = view().collectionView
        modifierGroupDataProvider.collectionViewHeightConstraint = view().collectionViewHeightConstraint
        self.modifierGroupDataProvider = modifierGroupDataProvider

        UILabel.appearance(whenContainedInInstancesOf: [UISegmentedControl.self]).numberOfLines = 0

    }

    func updateSelectedModifiers(_ modifiers: [Modification]) {
        selectedModifiers = modifiers
        changePricingAction()
    }
}
