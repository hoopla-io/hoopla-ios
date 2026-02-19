//
//  CheckoutViewController.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 18/02/26.
//

import UIKit

class CheckoutViewController: UIViewController, ViewSpecificController, @MainActor AlertViewController {
    // MARK: - Root View
    typealias RootView = CheckoutView
    
    // MARK: - Services
    var coordinator: Coordinator?
    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    let viewModel = ConfirmOrderViewModel()

    // MARK: - Attributes
    var drinkData: Drinks? {
        didSet {
            view().drinkLabel.text = "\(drinkData?.name ?? "")"
            view().drinkTitleLabel.text = "\(drinkData?.name ?? "")"
            if let imageUrl = drinkData?.pictureUrl {
                view().imageView.setImage(with: imageUrl)
            }
            view().drinkPriceLabel.text = ("+" + (drinkData?.productPrice?.formattedWithCurrency ?? "0"))
        }
    }
    var totalPrice: Double = 0.0 {
        didSet {
            view().totalPriceLabel.text = totalPrice.formattedWithCurrency
        }
    }
    var shopData: Shop? {
        didSet {
            view().shopLabel.text = shopData?.name
        }
    }
    var selectedSugar: Modification? {
        didSet {
            guard let selectedSugar else  { return }
            view().sugarTitleLabel.text = selectedSugar.modificationName
            view().sugarPriceLabel.text = ("+" + (selectedSugar.modificationPrice?.formattedWithCurrency ?? "0"))
            view().sugarStackView.isHidden = false
        }
    }
    var selectedSize: Modification? {
        didSet {
            guard let selectedSize else  { return }
            view().sizePriceLabel.text = ("+" + (selectedSize.modificationPrice?.formattedWithCurrency ?? "0"))
            view().sizeTitleLabel.text = selectedSize.modificationName
            view().sizeStackView.isHidden = false
        }
    }
    var selectedMilk: Modification? {
        didSet {
            guard let selectedMilk else  { return }
            view().milkPriceLabel.text = ("+" + (selectedMilk.modificationPrice?.formattedWithCurrency ?? "0"))
            view().milkTitleLabel.text = selectedMilk.modificationName
            view().milkStackView.isHidden = false
        }
    }
    var selectedSyrop: Modification? {
        didSet {
            guard let selectedSyrop else  { return }
            view().syropPriceLabel.text = ("+" + (selectedSyrop.modificationPrice?.formattedWithCurrency ?? "0"))
            view().syropTitleLabel.text = selectedSyrop.modificationName
            view().syropStackView.isHidden = false
        }
    }
    
    //MARK: - Actions
    @IBAction func cashbeckAction(_ sender: UISwitch) {
        guard let coordinator = coordinator as? MainCoordinator else { return }
        guard sender.isOn else { return }
        coordinator.pushToCashbeckVC()
    }
    
    @IBAction func confirmOrderAction(_ sender: Any) {
        Task { @MainActor in
            guard let shopId = shopData?.id, let drinkId = drinkData?.id else { return }
            await viewModel.createOrder(drinkId: drinkId, shopId: shopId, modifiers: [selectedSize, selectedSugar, selectedMilk, selectedSyrop])
        }
    }
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
    
}
// MARK: - Networking
extension CheckoutViewController: ConfirmOrderViewModelProtocol {
    func didFinishFetch(statusCode: Int) {
        guard let coordinator = coordinator as? MainCoordinator else { return }
        if statusCode == StatusCode.notEnoughBalance.rawValue {
            coordinator.pushToPaymentVC(amount: self.drinkData?.productPrice)
        } else if statusCode == StatusCode.success200.rawValue {
            showSuccessAlert(message: "success".localized)
            tabBarController?.selectedIndex = 2
            navigationController?.popToRootViewController(animated: false)
        }
    }
}

// MARK: - Other funcs
extension CheckoutViewController {
    private func appearanceSettings() {
        navigationItem.title = "checkout".localized
        viewModel.delegate = self
    }
}

