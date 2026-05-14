//
//  GetOrderViewModel.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 14/05/26.
//

import UIKit

protocol GetOrderViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: GetOrder?)
}

final class GetOrderViewModel {
    // MARK: - Attributes
    weak var delegate: GetOrderViewModelProtocol?
    
    // MARK: - Network call
    
    func getOrder(id: Int) {
        let url = "\(EndPoints.orders.rawValue)/\(id)/pickup-qr"
        delegate?.showActivityIndicator()
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: url, requestMethod: .get, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<GetOrder>.self, from: json)
                        self.delegate?.didFinishFetch(data: fetchedData.data)
                    } catch {
                        print("❌ JSON Decoding Error: \(error)")
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
                self.delegate?.hideActivityIndicator()
            })
        }
    }
    
}
