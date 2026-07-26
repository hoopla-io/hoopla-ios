//
//  CartViewController.swift
//  qahvazor-client
//

import UIKit

final class CartViewController: UIViewController, ViewSpecificController, @MainActor AlertViewController {
    typealias RootView = CartView

    var customSpinnerView = CustomSpinnerView()
    var isLoading = false
    var coordinator: CartCoordinator?

    private let viewModel = CartViewModel()
    private var cart: Cart?
    private var balance: Double = 0
    private var cashbackAmount: Double = Cashbeck.balance
    private var updatingItemIDs = Set<Int>()
    private var pendingOrderID: Int?
    private var shouldCheckPayment = false
    private var isCheckoutSubmitting = false

    override func loadView() {
        view = CartView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard UserDefaults.standard.isAuthed() else {
            cart = nil
            view().showEmptyState(isAuthenticated: false)
            navigationItem.rightBarButtonItem = nil
            return
        }

        viewModel.loadCart()
        viewModel.loadBalance()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard shouldCheckPayment, let pendingOrderID else { return }
        shouldCheckPayment = false
        viewModel.paymentStatus(orderId: pendingOrderID)
    }
}

private extension CartViewController {
    func configureUI() {
        navigationItem.title = "cartTitle".localized
        navigationItem.largeTitleDisplayMode = .never
        viewModel.delegate = self
        view().showEmptyState(isAuthenticated: UserDefaults.standard.isAuthed())

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshCart(_:)), for: .valueChanged)
        view().scrollView.refreshControl = refreshControl

        view().onPromoAction = { [weak self] code, isRemoving in
            guard let self else { return }
            isRemoving ? self.viewModel.removePromo() : self.viewModel.applyPromo(code: code)
        }
        view().onCommentFinished = { [weak self] comment in
            guard let self, comment != self.cart?.comment else { return }
            self.viewModel.saveComment(comment)
        }
        view().cashbackSwitch.addTarget(
            self,
            action: #selector(cashbeckAction(_:)),
            for: .valueChanged
        )
        view().cashbackSelectButton.addTarget(
            self,
            action: #selector(pushToCashbeckVC),
            for: .touchUpInside
        )
        view().onCheckout = { [weak self] in
            self?.checkout()
        }
    }

    func renderCart(_ cart: Cart?) {
        self.cart = cart
        updatingItemIDs.removeAll()
        view().configure(
            cart: cart,
            balance: balance,
            useCashback: view().cashbackSwitch.isOn,
            cashbackAmount: cashbackAmount
        )
        configureItemActions()
        updateClearButton()
    }

    func configureItemActions() {
        cart?.items?.forEach { [weak self] item in
            guard let self, let id = item.id, let itemView = view().itemViews[id] else { return }
            let quantity = max(item.quantity ?? 1, 1)
            itemView.onDecrease = { [weak self] in
                self?.updateItem(id: id, quantity: quantity - 1)
            }
            itemView.onIncrease = { [weak self] in
                self?.updateItem(id: id, quantity: quantity + 1)
            }
            itemView.onRemove = { [weak self] in
                self?.removeItem(id: id)
            }
        }
    }

    func updateClearButton() {
        guard cart?.items?.isEmpty == false else {
            navigationItem.rightBarButtonItem = nil
            return
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "trash.fill"),
            style: .plain,
            target: self,
            action: #selector(clearCartTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = .systemRed
    }

    func updateItem(id: Int, quantity: Int) {
        guard !updatingItemIDs.contains(id) else { return }
        updatingItemIDs.insert(id)
        view().setItem(id, loading: true)
        viewModel.update(itemId: id, quantity: quantity)
    }

    func removeItem(id: Int) {
        guard !updatingItemIDs.contains(id) else { return }
        updatingItemIDs.insert(id)
        view().setItem(id, loading: true)
        viewModel.remove(itemId: id)
    }

    func checkout() {
        guard cart?.items?.isEmpty == false, !isCheckoutSubmitting else { return }
        isCheckoutSubmitting = true
        view().checkoutButton.isEnabled = false
        let comment = view().comment
        view().commentTextView.delegate = nil
        view.endEditing(true)
        view().commentTextView.delegate = view()
        viewModel.checkout(
            comment: comment,
            useCashback: view().cashbackSwitch.isOn,
            cashbackAmount: cashbackAmountForOrder
        )
    }

    @objc func cashbeckAction(_ sender: UISwitch) {
        guard sender.isOn else {
            view().setCashback(amount: cashbackAmount, enabled: false)
            return
        }

        pushToCashbeckVC()
        view().setCashback(amount: cashbackAmount, enabled: false)
    }

    @objc func pushToCashbeckVC() {
        guard balance > 0, subtotalAfterPromocode > 0 else { return }
        coordinator?.pushToCashbeckVC(
            viewController: self,
            totalPrice: subtotalAfterPromocode,
            cashbackAmount: cashbackAmount
        )
    }

    func completeOrder(message: String = "successPurchased".localized) {
        finishCheckoutSubmission()
        pendingOrderID = nil
        cart = nil
        view().showEmptyState(isAuthenticated: true)
        updateClearButton()
        CartBadgeManager.shared.cartDidChange()
        showSuccessAlert(message: message)
        tabBarController?.selectTab(.orders)
    }

    func finishCheckoutSubmission() {
        isCheckoutSubmitting = false
        view().checkoutButton.isEnabled = true
    }

    var subtotalAfterPromocode: Double {
        let subtotal = max(cart?.subtotal ?? 0, 0)
        let discount = max(cart?.promoDiscount ?? 0, 0)
        return max(subtotal - discount, 0)
    }

    var cashbackAmountForOrder: Double {
        guard view().cashbackSwitch.isOn else { return cashbackAmount }
        return min(cashbackAmount, min(balance, subtotalAfterPromocode))
    }

    @objc func refreshCart(_ refreshControl: UIRefreshControl) {
        viewModel.loadCart()
        viewModel.loadBalance()
        refreshControl.endRefreshing()
    }

    @objc func clearCartTapped() {
        showAlertDestructive(
            title: "cartClearTitle".localized,
            message: "cartClearMessage".localized,
            preferredStyle: .alert,
            buttonTitle: "clear".localized
        ) { [weak self] in
            self?.viewModel.clearCart()
        }
    }
}

extension CartViewController: CartViewModelProtocol {
    func showAlertClosure(error: (APIError, String?)) {
        finishCheckoutSubmission()
        addErrorAlertView(error: error, completion: nil)
    }

    func didLoad(cart: Cart?) {
        renderCart(cart)
        CartBadgeManager.shared.cartDidChange()
    }

    func didLoad(balance: Double) {
        self.balance = balance
        if cashbackAmount == 0 {
            cashbackAmount = balance
        } else {
            cashbackAmount = min(cashbackAmount, balance)
        }
        view().configure(
            cart: cart,
            balance: balance,
            useCashback: view().cashbackSwitch.isOn,
            cashbackAmount: cashbackAmount
        )
        configureItemActions()
    }

    func didUpdate(cart: Cart?) {
        renderCart(cart)
    }

    func didClearCart() {
        renderCart(nil)
    }

    func didCheckout(data: Checkout?, statusCode: Int) {
        finishCheckoutSubmission()
        if let checkoutURL = data?.checkoutUrl, !checkoutURL.isEmpty {
            pendingOrderID = data?.orderId
            shouldCheckPayment = true
            openViaSafariVC(checkoutURL, from: self)
            return
        }

        if statusCode == StatusCode.success200.rawValue || statusCode == StatusCode.success201.rawValue {
            completeOrder()
        }
    }

    func didRecoverCheckout(order: OrderHistory) {
        finishCheckoutSubmission()
        if let checkoutURL = order.checkoutUrl, !checkoutURL.isEmpty {
            pendingOrderID = order.id
            shouldCheckPayment = true
            openViaSafariVC(checkoutURL, from: self)
        } else {
            coordinator?.showOrder(order)
        }
    }

    func didFinishPayment(status: String) {
        finishCheckoutSubmission()
        guard let orderStatus = OrderStatus(rawValue: status) else {
            showWarningAlert(message: status.localized)
            return
        }

        switch orderStatus {
        case .completed, .paid:
            completeOrder()
        case .cancelled, .error, .payment_failed, .payment_expired:
            showErrorAlert(message: status.localized)
        default:
            showWarningAlert(message: status.localized)
        }
    }
}

extension CartViewController: CashbeckViewProtocol {
    func didFinishCashbeck(cashbek: Double) {
        cashbackAmount = cashbek
        view().setCashback(amount: cashbek, enabled: true)
    }
}
