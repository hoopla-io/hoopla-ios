//
//  ShopsListViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 26/12/24.
//

import UIKit

protocol ShopsListViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: [Shop])
}

final class ShopsListViewModel {
    // MARK: - Attributes
    weak var delegate: ShopsListViewModelProtocol?
    
    // MARK: - Network call
    func getFilialsList(partnerId: Int) {
        let params: [String : Any] = [
            Parameters.partnerId.rawValue : partnerId
        ]
        
        JSONDownloader.shared.jsonTask(url: EndPoints.partnerShops.rawValue, requestMethod: .get, parameters: params, completionHandler: { [weak self]  (result) in
            guard let self = self else { return }
            switch result {
            case .Error(let error, let message):
                self.delegate?.showAlertClosure(error: (error,message))
            case .Success(let json):
                do {
                    let fetchedData = try CustomDecoder().decode(JSONData<[Shop]>.self, from: json)
                    guard let data = fetchedData.data else { self.delegate?.didFinishFetch(data: [Shop]())
                        return }
                    self.delegate?.didFinishFetch(data: data)
                } catch {
                    self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                }
            }
        })
    }
    
}


