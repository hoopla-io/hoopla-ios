//
//  ConfirmOrderViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 25/06/25.
//

import UIKit

protocol ConfirmOrderViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: WorkHour?, statusCode: Int)
    func didFinishFetch(data: Modifications?)
}

final class ConfirmOrderViewModel {
    // MARK: - Attributes
    weak var delegate: ConfirmOrderViewModelProtocol?
    
    // MARK: - Network call
    func createOrder(drinkId: Int, shopId: Int, modifiers: [Modification?]?) async {
        async let modifierList: [[String: Any]] = sortModifiers(modifiers)
        
        let parameters: [String: Any] = [
            Parameters.drinkId.rawValue: drinkId,
            Parameters.shopId.rawValue: shopId,
            Parameters.modifiers.rawValue : await modifierList,
        ]
        
        self.delegate?.showActivityIndicator()
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: EndPoints.createOrder.rawValue, requestMethod: .post, parameters: parameters, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<WorkHour>.self, from: json)
                        self.delegate?.didFinishFetch(data: fetchedData.data, statusCode: fetchedData.code)
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
                self.delegate?.hideActivityIndicator()
            })
        }
    }
    
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
                        self.delegate?.didFinishFetch(data: fetchedData.data?.modifications)
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
    
}
