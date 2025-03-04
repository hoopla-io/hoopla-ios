//
//  SubscriptionViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 11/01/25.
//

import UIKit

protocol SubscriptionViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: [Subscription])
    func didFinishFetchSuccessBought()
}

final class SubscriptionViewModel {
    // MARK: - Attributes
    weak var delegate: SubscriptionViewModelProtocol?
    
    // MARK: - Network call
    func getList() {
        
        JSONDownloader.shared.jsonTask(url: EndPoints.subscriptions.rawValue, requestMethod: .get, completionHandler: { [weak self]  (result) in
            guard let self = self else { return }
            switch result {
            case .Error(let error, let message):
                self.delegate?.showAlertClosure(error: (error,message))
            case .Success(let json):
                do {
                    let fetchedData = try CustomDecoder().decode(JSONData<[Subscription]>.self, from: json)
                    guard let data = fetchedData.data else { return }
                    self.delegate?.didFinishFetch(data: data)
                } catch {
                    self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                }
            }
        })
    }
    
    func subscriptionBuy(id: Int) {
        let param = [
            Parameters.subscriptionId.rawValue: id
        ]
        
        delegate?.showActivityIndicator()
        JSONDownloader.shared.jsonTask(url: EndPoints.subscriptionsBuy.rawValue, requestMethod: .post, parameters: param, completionHandler: { [weak self]  (result) in
            guard let self = self else { return }
            switch result {
            case .Error(let error, let message):
                self.delegate?.showAlertClosure(error: (error,message))
            case .Success(_):
                self.delegate?.didFinishFetchSuccessBought()
            }
            self.delegate?.hideActivityIndicator()
        })
    }
    
}


