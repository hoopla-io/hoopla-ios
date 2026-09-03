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
    var drinkData: Products? {
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
            refreshCheckoutTotals()
        }
    }
    var shopData: Shop? {
        didSet {
            view().shopLabel.text = shopData?.name
        }
    }
    var selectedModifiers = [Modification]() {
        didSet {
            configureModifierSummary()
        }
    }
    var cashbackAmount: Double = 0.0 {
        didSet {
            view().cashbackPriceLabel.text = "available".localized + ": " + cashbackAmount.formattedWithCurrency
        }
    }
    var orderedId: Int?
    var comment: String? {
        didSet {
            guard let comment, !comment.isEmpty else { return }
            view().commentLabel.text = comment
            view().commentStackView.isHidden = false
        }
    }
    var cashbackPercent: Int? {
        didSet {
            updateCashbackPercentSummary()
        }
    }
    var appliedPromocode: PromocodePreview? {
        didSet {
            refreshCheckoutTotals()
        }
    }

    override func loadView() {
        view = CheckoutView()
    }

    // MARK: - Actions
    @objc func cashbeckAction(_ sender: UISwitch) {
        guard sender.isOn else {
            view().oldPriceLabel.isHidden = true
            refreshCheckoutTotals()
            return
        }
        pushToCashbeckVC()
        view().cashbackSwitch.isOn = false
    }
    
    @objc func pushToCashbeckVC() {
        guard let coordinator = coordinator as? MainCoordinator else { return }
        coordinator.pushToCashbeckVC(viewController: self, totalPrice: subtotalAfterPromocode, cashbackAmount: cashbackAmount)
    }

    @objc func presentPromocodeVC() {
        guard let coordinator = coordinator as? MainCoordinator else { return }
        guard let shopId = shopData?.id, let drinkId = drinkData?.id else { return }
        coordinator.presentPromocodeVC(viewController: self, shopId: shopId, drinkId: drinkId, modifiers: selectedModifiers)
    }

    @objc func removePromocodeAction() {
        appliedPromocode = nil
    }
    
    @objc func confirmOrderAction(_ sender: Any) {
        Task { @MainActor in
            guard let shopId = shopData?.id, let drinkId = drinkData?.id else { return }
            await viewModel.createOrder(
                drinkId: drinkId,
                shopId: shopId,
                modifiers: selectedModifiers,
                useCashback: view().cashbackSwitch.isOn,
                cashbackAmount: cashbackAmountForOrder,
                comment: comment,
                promoCode: appliedPromocode?.code
            )
        }
    }
    
    // MARK: - Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceSettings()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateModifierCollectionViewHeight()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let orderedId else { return }
        viewModel.paymentStatus(orderId: orderedId)
    }
    
}
// MARK: - Networking
extension CheckoutViewController: CheckoutViewModelProtocol {
    func didFinishFetch(data: Checkout?, statusCode: Int) {
        if statusCode == StatusCode.needSubscription.rawValue {
            orderedId = data?.orderId
            guard let url = data?.checkoutUrl else { return }
            openViaSafariVC(url, from: self)
        } else if statusCode == StatusCode.success200.rawValue {
            didFinishFetch(status: "successPurchased".localized)
        }
    }
    
    func didFinishFetch(status: String) {
        Purchase.isPurchased = true
        showAlert(status)
        navigationController?.popToRootViewController(animated: true)
    }
    
    func showAlert(_ status: String) {
        guard status != "successPurchased".localized else {
            showSuccessAlert(message: status.localized)
            return
        }
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

        view().cashbackSwitch.addTarget(self, action: #selector(cashbeckAction(_:)), for: .touchUpInside)
        view().cashbackSelectButton.addTarget(self, action: #selector(pushToCashbeckVC), for: .touchUpInside)
        view().promoCodeButton.addTarget(self, action: #selector(presentPromocodeVC), for: .touchUpInside)
        view().removePromocodeButton.addTarget(self, action: #selector(removePromocodeAction), for: .touchUpInside)
        view().nextButton.addTarget(self, action: #selector(confirmOrderAction(_:)), for: .touchUpInside)
        
        cashbackAmount = Cashbeck.balance
        view().cashbackSwitch.isEnabled = Cashbeck.balance != 0
        view().cashbackSelectButton.isEnabled = Cashbeck.balance != 0
    }
}

// MARK: - Cashbeck
extension CheckoutViewController: CashbeckViewProtocol {
    func didFinishCashbeck(cashbek: Double) {
        view().cashbackSwitch.isOn = true
        
        self.cashbackAmount = cashbek
        refreshCheckoutTotals()
    }
}

extension CheckoutViewController: PromocodeViewControllerDelegate {
    func promocodeViewController(_ viewController: PromocodeViewController, didApply promocode: PromocodePreview) {
        appliedPromocode = promocode
    }
}

private extension CheckoutViewController {
    var subtotalAfterPromocode: Double {
        if let total = appliedPromocode?.total {
            return total
        }

        let discount = appliedPromocode?.discountAmount ?? 0
        return max(totalPrice - discount, 0)
    }

    var promocodeDiscountAmount: Double {
        if let discountAmount = appliedPromocode?.discountAmount {
            return discountAmount
        }

        guard let appliedPromocode else { return 0 }
        let subtotal = appliedPromocode.subtotal ?? totalPrice
        let total = appliedPromocode.total ?? subtotal
        return max(subtotal - total, 0)
    }

    func refreshCheckoutTotals() {
        if let appliedPromocode {
            view().showAppliedPromocode(
                code: appliedPromocode.code ?? "",
                discountAmount: promocodeDiscountAmount
            )
        } else {
            view().resetPromocode()
        }

        let subtotal = subtotalAfterPromocode
        let cashback = view().cashbackSwitch.isOn ? min(cashbackAmount, subtotal) : 0
        let finalPrice = max(subtotal - cashback, 0)

        view().totalPriceLabel.text = finalPrice.formattedWithCurrency

        if view().cashbackSwitch.isOn, cashback > 0 {
            let underlineAttribute = [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            let underlineAttributedString = NSAttributedString(
                string: subtotal.formattedWithCurrency,
                attributes: underlineAttribute
            )
            view().oldPriceLabel.attributedText = underlineAttributedString
            view().oldPriceLabel.isHidden = false
        } else {
            view().oldPriceLabel.attributedText = nil
            view().oldPriceLabel.text = nil
            view().oldPriceLabel.isHidden = true
        }

        updateCashbackPercentSummary()
    }

    var cashbackAmountForOrder: Double {
        guard view().cashbackSwitch.isOn else { return cashbackAmount }
        return min(cashbackAmount, subtotalAfterPromocode)
    }

    func updateCashbackPercentSummary() {
        guard let cashbackPercent, cashbackPercent > 0 else {
            view().cashbackPercentStackView.isHidden = true
            return
        }

        let cashback = subtotalAfterPromocode / 100 * Double(cashbackPercent)
        view().cashbackPercentTitleLabel.text = ("youGet".localized + " (\(cashbackPercent)%)")
        view().cashbackPercentLabel.text = "+" + cashback.formattedWithCurrency
        view().cashbackPercentStackView.isHidden = false
    }

    func configureModifierSummary() {
        view().modifierCollectionView.dataSource = self
        view().modifierCollectionView.delegate = self
        view().modifierCollectionView.reloadData()
        updateModifierCollectionViewHeight()
    }

    func updateModifierCollectionViewHeight() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let collectionView = self.view().modifierCollectionView
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.layoutIfNeeded()
            let height = ceil(collectionView.collectionViewLayout.collectionViewContentSize.height)
            guard abs(self.view().modifierCollectionViewHeightConstraint.constant - height) > 0.5 else { return }

            self.view().modifierCollectionViewHeightConstraint.constant = height
            self.view().layoutIfNeeded()
        }
    }
}
