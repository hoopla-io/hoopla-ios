//
//  CartViewModel.swift
//  qahvazor-client
//

import Foundation
import Alamofire

protocol CartViewModelProtocol: ViewModelProtocol {
    func didLoad(cart: Cart?)
    func didLoad(balance: Double)
    func didUpdate(cart: Cart?)
    func didClearCart()
    func didCheckout(data: Checkout?, statusCode: Int)
    func didRecoverCheckout(order: OrderHistory)
    func didFinishPayment(status: String)
}

final class CartViewModel {
    weak var delegate: CartViewModelProtocol?

    func loadCart() {
        delegate?.showActivityIndicator()
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(
                url: EndPoints.cart.rawValue,
                requestMethod: .get,
                completionHandler: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .Error(let error, let message):
                        self.delegate?.showAlertClosure(error: (error, message))
                    case .Success(let data):
                        do {
                            let response = try CustomDecoder().decode(JSONData<Cart>.self, from: data)
                            self.delegate?.didLoad(cart: response.data)
                        } catch {
                            self.delegate?.showAlertClosure(error: (.invalidData, nil))
                        }
                    }
                    self.delegate?.hideActivityIndicator()
                }
            )
        }
    }

    func loadBalance() {
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(
                url: EndPoints.getMe.rawValue,
                requestMethod: .get,
                completionHandler: { [weak self] result in
                    guard let self else { return }
                    if case .Success(let data) = result,
                       let account = try? CustomDecoder().decode(JSONData<Account>.self, from: data).data {
                        let balance = max(account.balance ?? 0, 0)
                        Cashbeck.balance = balance
                        self.delegate?.didLoad(balance: balance)
                    }
                }
            )
        }
    }

    func update(itemId: Int, quantity: Int) {
        mutateCart(
            url: "\(EndPoints.cartItems.rawValue)/\(itemId)",
            method: .patch,
            parameters: [Parameters.quantity.rawValue: max(quantity, 0)]
        )
    }

    func remove(itemId: Int) {
        mutateCart(
            url: "\(EndPoints.cartItems.rawValue)/\(itemId)",
            method: .delete
        )
    }

    func applyPromo(code: String) {
        mutateCart(
            url: EndPoints.cartPromo.rawValue,
            method: .post,
            parameters: [Parameters.code.rawValue: code]
        )
    }

    func removePromo() {
        mutateCart(url: EndPoints.cartPromo.rawValue, method: .delete)
    }

    func saveComment(_ comment: String?, completion: (() -> Void)? = nil) {
        let parameters: [String: Any] = [
            Parameters.comment.rawValue: comment ?? NSNull()
        ]

        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(
                url: EndPoints.cartComment.rawValue,
                requestMethod: .post,
                parameters: parameters,
                completionHandler: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .Error(let error, let message):
                        self.delegate?.showAlertClosure(error: (error, message))
                    case .Success(let data):
                        do {
                            let cart = try CustomDecoder().decode(JSONData<Cart>.self, from: data).data
                            self.delegate?.didUpdate(cart: cart)
                            CartBadgeManager.shared.cartDidChange()
                            completion?()
                        } catch {
                            self.delegate?.showAlertClosure(error: (.invalidData, nil))
                        }
                    }
                }
            )
        }
    }

    func clearCart() {
        delegate?.showActivityIndicator()
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(
                url: EndPoints.cart.rawValue,
                requestMethod: .delete,
                completionHandler: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .Error(let error, let message):
                        self.delegate?.showAlertClosure(error: (error, message))
                    case .Success:
                        self.delegate?.didClearCart()
                        CartBadgeManager.shared.cartDidChange()
                    }
                    self.delegate?.hideActivityIndicator()
                }
            )
        }
    }

    func checkout(comment: String?, useCashback: Bool, cashbackAmount: Double) {
        let performCheckout: () -> Void = { [weak self] in
            guard let self else { return }
            self.performCheckout(useCashback: useCashback, cashbackAmount: cashbackAmount)
        }

        saveComment(comment, completion: performCheckout)
    }

    func paymentStatus(orderId: Int) {
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(
                url: "user/orders/\(orderId)/payment-status",
                requestMethod: .get,
                completionHandler: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .Error(let error, let message):
                        self.delegate?.showAlertClosure(error: (error, message))
                    case .Success(let data):
                        do {
                            let response = try CustomDecoder().decode(JSONData<Checkout>.self, from: data)
                            self.delegate?.didFinishPayment(status: response.data?.status ?? "error")
                        } catch {
                            self.delegate?.showAlertClosure(error: (.invalidData, nil))
                        }
                    }
                }
            )
        }
    }

    private func mutateCart(
        url: String,
        method: HTTPMethod,
        parameters: [String: Any]? = nil
    ) {
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(
                url: url,
                requestMethod: method,
                parameters: parameters,
                completionHandler: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .Error(let error, let message):
                        self.delegate?.showAlertClosure(error: (error, message))
                    case .Success(let data):
                        do {
                            let cart = try CustomDecoder().decode(JSONData<Cart>.self, from: data).data
                            self.delegate?.didUpdate(cart: cart)
                            CartBadgeManager.shared.cartDidChange()
                        } catch {
                            self.delegate?.showAlertClosure(error: (.invalidData, nil))
                        }
                    }
                }
            )
        }
    }

    private func performCheckout(useCashback: Bool, cashbackAmount: Double) {
        let parameters: [String: Any] = [
            Parameters.use_cashback.rawValue: useCashback,
            Parameters.cashback_amount.rawValue: useCashback ? max(cashbackAmount, 0) : 0
        ]

        delegate?.showActivityIndicator()
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(
                url: EndPoints.cartCheckout.rawValue,
                requestMethod: .post,
                parameters: parameters,
                timeout: 35,
                allowsRetry: false,
                completionHandler: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .Error(let error, let message):
                        if case .requestFailed = error {
                            self.recoverCheckout()
                        } else {
                            self.delegate?.showAlertClosure(error: (error, message))
                            self.loadCart()
                        }
                    case .Success(let data):
                        do {
                            let response = try CustomDecoder().decode(JSONData<Checkout>.self, from: data)
                            self.delegate?.didCheckout(data: response.data, statusCode: response.code)
                        } catch {
                            self.delegate?.showAlertClosure(error: (.invalidData, nil))
                        }
                    }
                    self.delegate?.hideActivityIndicator()
                }
            )
        }
    }

    private func recoverCheckout() {
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(
                url: EndPoints.activeOrders.rawValue,
                requestMethod: .get,
                completionHandler: { [weak self] result in
                    guard let self else { return }
                    if case .Success(let data) = result,
                       let orders = try? CustomDecoder().decode(JSONData<[OrderHistory]>.self, from: data).data,
                       let pending = orders.first(where: Self.isRecentPendingOrder) {
                        self.delegate?.didRecoverCheckout(order: pending)
                    } else {
                        self.delegate?.showAlertClosure(error: (.requestFailed, nil))
                    }
                }
            )
        }
    }

    private static func isRecentPendingOrder(_ order: OrderHistory) -> Bool {
        guard order.checkoutUrl?.isEmpty == false else { return false }
        guard var timestamp = order.purchasedAtUnix else { return true }
        if timestamp > 10_000_000_000 {
            timestamp /= 1_000
        }
        return abs(Int(Date().timeIntervalSince1970) - timestamp) <= 10 * 60
    }
}
