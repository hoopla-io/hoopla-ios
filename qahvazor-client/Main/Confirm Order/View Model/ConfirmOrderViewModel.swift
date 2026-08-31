//
//  ConfirmOrderViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 25/06/25.
//

import UIKit

protocol ConfirmOrderViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: [ModifierGroups]?, cashbackPercent: Int?)
    func didAddToCart(cart: Cart)
    func didEncounterCartConflict()
}

final class ConfirmOrderViewModel {
    // MARK: - Attributes
    weak var delegate: ConfirmOrderViewModelProtocol?
    
    // MARK: - Network call
    func validateOrder(drinkId: Int, shopId: Int) {
        let parameters: [String: Any] = [
            Parameters.drinkId.rawValue: drinkId,
            Parameters.shopId.rawValue: shopId
        ]
        
        self.delegate?.showActivityIndicator()
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: EndPoints.validateOrder.rawValue, requestMethod: .post, parameters: parameters, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<ConfirmDrink>.self, from: json)
                        self.delegate?.didFinishFetch(data: fetchedData.data?.modifierGroups, cashbackPercent: fetchedData.data?.cashbackPercent)
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
                self.delegate?.hideActivityIndicator()
            })
        }
    }

    func addToCart(
        drinkId: Int,
        shopId: Int,
        quantity: Int,
        modifiers: [Modification]
    ) {
        let parameters: [String: Any] = [
            Parameters.shopId.rawValue: shopId,
            Parameters.drinkId.rawValue: drinkId,
            Parameters.quantity.rawValue: max(quantity, 1),
            Parameters.modifiers.rawValue: modifiers.map(Self.modifierParameters)
        ]

        delegate?.showActivityIndicator()
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(
                url: EndPoints.cartItems.rawValue,
                requestMethod: .post,
                parameters: parameters,
                completionHandler: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .Error(.cartConflict, _):
                        self.delegate?.didEncounterCartConflict()
                    case .Error(let error, let message):
                        self.delegate?.showAlertClosure(error: (error, message))
                    case .Success(let data):
                        do {
                            let response = try CustomDecoder().decode(JSONData<Cart>.self, from: data)
                            guard let cart = response.data else {
                                self.delegate?.showAlertClosure(error: (.invalidData, nil))
                                self.delegate?.hideActivityIndicator()
                                return
                            }
                            self.delegate?.didAddToCart(cart: cart)
                            CartBadgeManager.shared.cartDidChange()
                        } catch {
                            self.delegate?.showAlertClosure(error: (.invalidData, nil))
                        }
                    }
                    self.delegate?.hideActivityIndicator()
                }
            )
        }
    }

    func clearCart(completion: @escaping () -> Void) {
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
                        self.delegate?.hideActivityIndicator()
                    case .Success:
                        CartBadgeManager.shared.cartDidChange()
                        self.delegate?.hideActivityIndicator()
                        completion()
                    }
                }
            )
        }
    }

    private static func modifierParameters(_ modifier: Modification) -> [String: Any] {
        var result = [String: Any]()
        if let value = modifier.modificationGroupId {
            result[Parameters.modifierGroupId.rawValue] = value
        }
        if let value = modifier.modificationId {
            result[Parameters.modifierId.rawValue] = value
        }
        if let value = modifier.modificationKey {
            result[Parameters.modifierKey.rawValue] = value
        }
        if let value = modifier.modificationName {
            result["modificationName"] = value
        }
        if let value = modifier.modificationPrice {
            result[Parameters.modifierPrice.rawValue] = value
        }
        return result
    }
    
}
