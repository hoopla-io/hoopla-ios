//
//  HistoryViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 10/01/25.
//

import UIKit

protocol HistoryViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: [OrderHistory], meta: Meta?)
    func didFinishFetch(data: OrderHistory?)
    func didFinishFetchCancel()
}

extension HistoryViewModelProtocol {
    func didFinishFetch(data: [OrderHistory], meta: Meta?) {}
    func didFinishFetch(data: OrderHistory?) {}
    func didFinishFetchCancel() {}
}

final class HistoryViewModel {
    // MARK: - Attributes
    weak var delegate: HistoryViewModelProtocol?
    
    // MARK: - Network call
    func getOrderHistoryList(page: Int = 1, itemsPerPage: Int = 16) {
        let params: [String : String] = [
            Parameters.page.rawValue : String(page),
            Parameters.itemsPerPage.rawValue : String(itemsPerPage)
        ]
        
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: EndPoints.ordersList.rawValue, requestMethod: .get, parameters: params, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<[OrderHistory]>.self, from: json)
                        guard let data = fetchedData.data else {
                            let emptyData: [OrderHistory] = []
                            self.delegate?.didFinishFetch(data: emptyData, meta: nil)
                            return
                        }
                        self.delegate?.didFinishFetch(data: data, meta: fetchedData.meta)
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
            })
        }
    }
    
    func getOrderHistoryDetail(id: Int) {
        let url = "\(EndPoints.orders.rawValue)/\(id)"
        delegate?.showActivityIndicator()
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: url, requestMethod: .get, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<OrderHistory>.self, from: json)
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
    
    func cancelOrder(id: Int) {
        let url = "\(EndPoints.orders.rawValue)/\(id)/cancel"
        delegate?.showActivityIndicator()
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: url, requestMethod: .post, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(_):
                    self.delegate?.didFinishFetchCancel()
                }
                self.delegate?.hideActivityIndicator()
            })
        }
    }
    
}


