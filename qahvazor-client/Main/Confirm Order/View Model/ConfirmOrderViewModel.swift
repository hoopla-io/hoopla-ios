//
//  ConfirmOrderViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 25/06/25.
//

import UIKit

protocol ConfirmOrderViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: [ModifierGroups]?)
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
                        self.delegate?.didFinishFetch(data: fetchedData.data?.modifierGroups)
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
                self.delegate?.hideActivityIndicator()
            })
        }
    }
    
}
