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
    let viewModel = CheckoutViewModel()

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
    var cashbackAmount: Double = 0.0 {
        didSet {
            view().cashbackPriceLabel.text = cashbackAmount.formattedWithCurrency
        }
    }
    var orderedId: Int?
    
    //MARK: - Actions
    @IBAction func cashbeckAction(_ sender: UISwitch) {
        guard sender.isOn else {
            view().oldPriceLabel.isHidden = true
            view().totalPriceLabel.text = totalPrice.formattedWithCurrency
            return
        }
        pushToCashbeckVC()
        view().cashbackSwitch.isOn = false
    }
    
    @objc func pushToCashbeckVC() {
        guard let coordinator = coordinator as? MainCoordinator else { return }
        coordinator.pushToCashbeckVC(viewController: self, totalPrice: totalPrice, cashbackAmount: cashbackAmount)
    }
    
    @IBAction func confirmOrderAction(_ sender: Any) {
        Task { @MainActor in
            guard let shopId = shopData?.id, let drinkId = drinkData?.id else { return }
            await viewModel.createOrder(drinkId: drinkId, shopId: shopId, modifiers: [selectedSize, selectedSugar, selectedMilk, selectedSyrop], useCashback: view().cashbackSwitch.isOn, cashbackAmount: cashbackAmount)
        }
    }
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let orderedId else { return }
        viewModel.paymentStatus(orderId: orderedId)
    }
    
}
// MARK: - Networking
extension CheckoutViewController: CheckoutViewModelProtocol {
    func didFinishFetch(data: Checkout?) {
        orderedId = data?.orderId
        guard let url = data?.checkoutUrl else { return }
        openViaSafariVC(url, from: self)
    }
    
    func didFinishFetch(status: String) {
        Purchase.isPurchased = true
        showAlert(status)
        navigationController?.popToRootViewController(animated: true)
    }
    
    func showAlert(_ status: String) {
        guard let colorType = OrderStatus(rawValue: status) else {
            showWarningAlert(message: status.localized)
            return
        }
        switch colorType {
        case .cancelled, .error, .payment_failed, .payment_expired:
            showErrorAlert(message: status.localized)
        case .completed, .paid:
            showSuccessAlert(message: status.localized)
        default:
            showWarningAlert(message: status.localized)
        }
    }
}

// MARK: - Other funcs
extension CheckoutViewController {
    private func appearanceSettings() {
        navigationItem.title = "checkout".localized
        viewModel.delegate = self
        
        cashbackAmount = Cashbeck.balance
        view().cashbackSwitch.isEnabled = Cashbeck.balance != 0
        
        guard Cashbeck.balance != 0 else { return }
        let tap = UITapGestureRecognizer(target: self, action: #selector(pushToCashbeckVC))
        view().cashbackContainerView.addGestureRecognizer(tap)
    }
}

// MARK: - Cashbeck
extension CheckoutViewController: CashbeckViewProtocol {
    func didFinishCashbeck(cashbek: Double) {
        view().cashbackSwitch.isOn = true
        
        self.cashbackAmount = cashbek
        
        var finalPrice = totalPrice - cashbek
        if finalPrice < 0 {
            finalPrice = 0
        }
        view().totalPriceLabel.text = finalPrice.formattedWithCurrency
        view().oldPriceLabel.text = totalPrice.formattedWithCurrency
        view().oldPriceLabel.isHidden = false
        
        let underlineAttribute = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: "\(totalPrice.formattedWithCurrency)", attributes: underlineAttribute)
        view().oldPriceLabel.attributedText = underlineAttributedString
    }
}
