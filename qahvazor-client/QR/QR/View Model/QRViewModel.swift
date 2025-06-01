//
//  QRViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 10/01/25.
//

import UIKit

protocol QRViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: QR)
    func didFinishFetch(data: [OrderHistory]?)
    func didFinishFetch(data: Limit?)
}

final class QRViewModel {
    // MARK: - Attributes
    weak var delegate: QRViewModelProtocol?
    
    // MARK: - Network call
    func getQRCode() {
        
        JSONDownloader.shared.jsonTask(url: EndPoints.qrCode.rawValue, requestMethod: .get, completionHandler: { [weak self]  (result) in
            guard let self = self else { return }
            switch result {
            case .Error(let error, let message):
                self.delegate?.showAlertClosure(error: (error,message))
            case .Success(let json):
                do {
                    let fetchedData = try CustomDecoder().decode(JSONData<QR>.self, from: json)
                    guard let data = fetchedData.data else { return }
                    self.delegate?.didFinishFetch(data: data)
                } catch {
                    self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                }
            }
        })
    }
    
    func getOrderHistoryList() {
        
        JSONDownloader.shared.jsonTask(url: EndPoints.orders.rawValue, requestMethod: .get, completionHandler: { [weak self]  (result) in
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
    
    func getDrinksLimit() {
        
        JSONDownloader.shared.jsonTask(url: EndPoints.drinksLimit.rawValue, requestMethod: .get, completionHandler: { [weak self]  (result) in
            guard let self = self else { return }
            switch result {
            case .Error(let error, let message):
                self.delegate?.showAlertClosure(error: (error,message))
            case .Success(let json):
                do {
                    let fetchedData = try CustomDecoder().decode(JSONData<Limit>.self, from: json)
                    self.delegate?.didFinishFetch(data: fetchedData.data)
                } catch {
                    self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                }
            }
        })
    }

    
}


