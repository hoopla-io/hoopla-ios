//
//  CheckoutViewModel.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 21/02/26.
//

import UIKit

protocol CheckoutViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: Checkout?, statusCode: Int)
    func didFinishFetch(status: String)
}

final class CheckoutViewModel {
    // MARK: - Attributes
    weak var delegate: CheckoutViewModelProtocol?
    
    // MARK: - Network call
    func createOrder(drinkId: Int, shopId: Int, modifiers: [Modification?]?, useCashback: Bool, cashbackAmount: Double) async {
        async let modifierList: [[String: Any]] = sortModifiers(modifiers)
        
        let parameters: [String: Any] = [
            Parameters.drinkId.rawValue: drinkId,
            Parameters.shopId.rawValue: shopId,
            Parameters.modifiers.rawValue : await modifierList,
            Parameters.cashback_amount.rawValue : cashbackAmount,
            Parameters.use_cashback.rawValue : useCashback
        ]
        
        self.delegate?.showActivityIndicator()
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: EndPoints.createOrderRahmat.rawValue, requestMethod: .post, parameters: parameters, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<Checkout>.self, from: json)
                        self.delegate?.didFinishFetch(data: fetchedData.data, statusCode: fetchedData.code)
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
                self.delegate?.hideActivityIndicator()
            })
        }
    }
    
    func sortModifiers(_ data: [Modification?]?) async -> [[String: Any]] {
        guard let data, !data.isEmpty else { return [] }
        
        return data.compactMap { item in
            guard
                let modifierId    = item?.modificationId,
                let modifierKey   = item?.modificationKey,
                let modifierPrice = item?.modificationPrice
            else {
                return nil
            }
            
            return [
                Parameters.modifierId.rawValue             : modifierId,
                Parameters.modifierKey.rawValue            : modifierKey,
                Parameters.modifierPrice.rawValue          : modifierPrice,
                Parameters.modifierGroupId.rawValue        : item?.modificationGroupId ?? ""
            ]
        }
    }
    
    func paymentStatus(orderId: Int) {
        let url = "user/orders/\(orderId)/payment-status"
        
        delegate?.showActivityIndicator()
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: url, requestMethod: .get, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<Checkout>.self, from: json)
                        guard let status = fetchedData.data?.status else {
                            self.delegate?.didFinishFetch(status: "error")
                            return
                        }
                        self.delegate?.didFinishFetch(status: status)
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
                self.delegate?.hideActivityIndicator()
            })
        }
    }
    
}

