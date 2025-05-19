//
//  PaymentViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 05/03/25.
//


import UIKit

protocol PaymentViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: [PaymentService])
    func didFinishFetch(data: PaymentCheckout)
}

final class PaymentViewModel {
    // MARK: - Attributes
    weak var delegate: PaymentViewModelProtocol?
    
    // MARK: - Network call
    func getListPayment() {
        
        JSONDownloader.shared.jsonTask(url: EndPoints.payServices.rawValue, requestMethod: .get, completionHandler: { [weak self]  (result) in
            guard let self = self else { return }
            switch result {
            case .Error(let error, let message):
                self.delegate?.showAlertClosure(error: (error,message))
            case .Success(let json):
                do {
                    let fetchedData = try CustomDecoder().decode(JSONData<[PaymentService]>.self, from: json)
                    guard let data = fetchedData.data else { return }
                    self.delegate?.didFinishFetch(data: data)
                } catch {
                    self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                }
            }
        })
    }
    
    func topUp(serviceId: Int, amount: String) {
        
        let params: [String : String] = [
            Parameters.id.rawValue : String(serviceId),
            Parameters.amount.rawValue : amount
        ]
        
        delegate?.showActivityIndicator()
        JSONDownloader.shared.jsonTask(url: EndPoints.topUp.rawValue, requestMethod: .get, parameters: params, completionHandler: { [weak self]  (result) in
            guard let self = self else { return }
            switch result {
            case .Error(let error, let message):
                self.delegate?.showAlertClosure(error: (error,message))
            case .Success(let json):
                do {
                    let fetchedData = try CustomDecoder().decode(JSONData<PaymentCheckout>.self, from: json)
                    guard let data = fetchedData.data else { return }
                    self.delegate?.didFinishFetch(data: data)
                } catch {
                    self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                }
            }
            self.delegate?.hideActivityIndicator()
        })
    }
}

