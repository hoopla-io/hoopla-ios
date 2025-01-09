//
//  ShopDetailViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 09/01/25.
//

import UIKit

protocol ShopDetailViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: Shop)
}

final class ShopDetailViewModel {
    // MARK: - Attributes
    weak var delegate: ShopDetailViewModelProtocol?
    
    // MARK: - Network call
    func getShopInfo(shopId: Int) {
        let params: [String : Any] = [
            Parameters.shopId.rawValue : shopId
        ]
        
        JSONDownloader.shared.jsonTask(url: EndPoints.shop.rawValue, requestMethod: .get, parameters: params, completionHandler: { [weak self]  (result) in
            guard let self = self else { return }
            switch result {
            case .Error(let error, let message):
                self.delegate?.showAlertClosure(error: (error,message))
            case .Success(let json):
                do {
                    let fetchedData = try CustomDecoder().decode(JSONData<Shop>.self, from: json)
                    guard let data = fetchedData.data else { return }
                    self.delegate?.didFinishFetch(data: data)
                } catch {
                    self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                }
            }
        })
    }
    
}

