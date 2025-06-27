//
//  ConfirmOrderViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 25/06/25.
//

import UIKit

protocol ConfirmOrderViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: WorkHour?, statusCode: Int)
}

final class ConfirmOrderViewModel {
    // MARK: - Attributes
    weak var delegate: ConfirmOrderViewModelProtocol?
    
    // MARK: - Network call
    func createOrder(drinkId: Int, shopId: Int) {
        let parameters: [String: Any] = [
            Parameters.drinkId.rawValue: drinkId,
            Parameters.shopId.rawValue: shopId
        ]
        
        self.delegate?.showActivityIndicator()
        JSONDownloader.shared.jsonTask(url: EndPoints.createOrder.rawValue, requestMethod: .post, parameters: parameters, completionHandler: { [weak self]  (result) in
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
