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
            baseProductPrice = drinkData?.productPrice ?? 0.0
            refreshPrice()
        }
    }
    private var baseProductPrice: Double = 0
    private var quantity = 1
    var productPrice: Double = 0.0 {
        didSet {
            view().setOrderButtonTitle(
                "addToCart".localized + " · " + productPrice.formattedWithCurrency
            )
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
    
    // MARK: - Life cycles
    override func loadView() {
        view = ConfirmOrderView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }

    // MARK: - Actions
    private func confirmOrderAction() {
        if let validationMessage = modifierGroupDataProvider?.validationMessage() {
            showWarningAlert(message: validationMessage)
            return
        }

        addToCart()
    }
    
    func changePricingAction() {
        let basePrice = drinkData?.productPrice ?? 0.0

        let modifiersPrice = selectedModifiers.reduce(0.0) {
            $0 + ($1.modificationPrice ?? 0.0)
        }
        productPrice = (basePrice + modifiersPrice) * Double(quantity)
    }
}

// MARK: - Networking
extension ConfirmOrderViewController: ConfirmOrderViewModelProtocol {
    func didFinishFetch(data: [ModifierGroups]?, cashbackPercent: Int?) {
        let groups = data?.filter { $0.options?.isEmpty == false } ?? []
//        let hasRequiredModifiers = groups.contains { ($0.minSelect ?? 0) > 0 }
//
//        if !hasRequiredModifiers {
//            addToCart()
//            return
//        }

        view().collectionView.isHidden = groups.isEmpty
        if groups.isEmpty {
            view().collectionViewHeightConstraint.constant = 0
        }

        modifierGroupDataProvider?.groups = groups
        updateSelectedModifiers([])
        
        self.cashbackPercent = cashbackPercent
    }

    func didAddToCart(cart: Cart) {
        showSuccessAlert(message: "cartAdded".localized)
        navigationController?.popViewController(animated: true)
    }

    func didEncounterCartConflict() {
        let alert = CartConflictAlertViewController()
        alert.modalPresentationStyle = .overFullScreen
        alert.modalTransitionStyle = .crossDissolve
        alert.onClearAndAdd = { [weak self] in
            guard let self else { return }
            self.viewModel.clearCart { [weak self] in
                self?.addToCart()
            }
        }
        present(alert, animated: true)
    }
}
// MARK: - Other funcs
extension ConfirmOrderViewController {
    private func appearanceSettings() {
        navigationItem.largeTitleDisplayMode = .never
        viewModel.delegate = self
        navigationItem.title = "orderSummary".localized
        view().textView.isHidden = true
        view().onConfirmOrder = { [weak self] in
            self?.confirmOrderAction()
        }
        view().onDecreaseQuantity = { [weak self] in
            guard let self, self.quantity > 1 else { return }
            self.quantity -= 1
            self.refreshPrice()
        }
        view().onIncreaseQuantity = { [weak self] in
            guard let self, self.quantity < 99 else { return }
            self.quantity += 1
            self.refreshPrice()
        }

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

    private func refreshPrice() {
        view().setQuantity(quantity)
        changePricingAction()
    }

    private func addToCart() {
        guard let shopId = shopData?.id ?? shopData?.shopId,
              let drinkId = drinkData?.id else { return }
        viewModel.addToCart(
            drinkId: drinkId,
            shopId: shopId,
            quantity: quantity,
            modifiers: selectedModifiers
        )
    }
}
