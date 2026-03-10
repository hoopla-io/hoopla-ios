//
//  QRViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 10/01/25.
//

import UIKit

protocol QRViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: [OrderHistory]?)
}

final class QRViewModel {
    // MARK: - Attributes
    weak var delegate: QRViewModelProtocol?
    
    // MARK: - Network call
    func getOrderHistoryList() {
        
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: EndPoints.orders.rawValue, requestMethod: .get, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<[OrderHistory]>.self, from: json)
                        self.delegate?.didFinishFetch(data: fetchedData.data)
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
            })
        }
    }
    
}


