//
//  MainViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 26/12/24.
//

import UIKit

protocol MainViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: [Shop])
    func didFinishFetch(data: [Stories])
    func didFinishFetch(data: Stories)
    func didFinishFetch(data: [Categories])
    func didFinishFetch(data: [OrderHistory])
    func didFinishFetch(feedback: OrderHistory)
}

final class MainViewModel {
    // MARK: - Attributes
    weak var delegate: MainViewModelProtocol?
    
    // MARK: - Network call
    func getList(categoryId: Int? = nil) {
        var param: [String : Any ] = [
            Parameters.long.rawValue : Coordinate.longitude,
            Parameters.lat.rawValue : Coordinate.latitude
        ]
        
        if let categoryId = categoryId {
            param[Parameters.categoryId.rawValue] = categoryId
        }
        
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: EndPoints.nearShops.rawValue, requestMethod: .get, parameters: param, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<[Shop]>.self, from: json)
                        guard let data = fetchedData.data else {
                            let emptyData: [Shop] = []
                            self.delegate?.didFinishFetch(data: emptyData)
                            return
                        }
                        self.delegate?.didFinishFetch(data: data)
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
            })
        }
    }
    
    func getStories() {
        
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: EndPoints.storiesList.rawValue, requestMethod: .get, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<[Stories]>.self, from: json)
                        guard let data = fetchedData.data else { return }
                        self.delegate?.didFinishFetch(data: data)
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
            })
        }
    }
    
    func getStoryDetail(
        id: Int,
        showsActivityIndicator: Bool = true,
        completion: ((Result<Stories>) -> Void)? = nil
    ) {
        let url = "stories/show/\(id)"
        if showsActivityIndicator {
            delegate?.showActivityIndicator()
        }
        
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: url, requestMethod: .get, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                defer {
                    if showsActivityIndicator {
                        self.delegate?.hideActivityIndicator()
                    }
                }

                func deliver(_ result: Result<Stories>) {
                    if let completion {
                        completion(result)
                        return
                    }

                    switch result {
                    case .Success(let data):
                        self.delegate?.didFinishFetch(data: data)
                    case .Error(let error, let message):
                        self.delegate?.showAlertClosure(error: (error, message))
                    }
                }

                switch result {
                case .Error(let error, let message):
                    deliver(.Error(error, message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<Stories>.self, from: json)
                        guard let data = fetchedData.data else {
                            deliver(.Error(.invalidData))
                            return
                        }
                        deliver(.Success(data))
                    } catch {
                        deliver(.Error(.invalidData))
                    }
                }
            })
        }
    }
    
    func getCategories() {
        
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: EndPoints.categories.rawValue, requestMethod: .get, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<[Categories]>.self, from: json)
                        guard let data = fetchedData.data else { return }
                        self.delegate?.didFinishFetch(data: data)
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
            })
        }
    }

    func getActiveOrders() {
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(
                url: EndPoints.activeOrders.rawValue,
                requestMethod: .get,
                completionHandler: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .Error(let error, let message):
                        self.delegate?.showAlertClosure(error: (error, message))
                    case .Success(let json):
                        do {
                            let fetchedData = try CustomDecoder().decode(JSONData<[OrderHistory]>.self, from: json)
                            self.delegate?.didFinishFetch(data: fetchedData.data ?? [])
                        } catch {
                            self.delegate?.showAlertClosure(error: (.invalidData, nil))
                        }
                    }
                }
            )
        }
    }

    func getPendingFeedback() {
        
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: EndPoints.pending.rawValue, requestMethod: .get, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<OrderHistory>.self, from: json)
                        guard let data = fetchedData.data else { return }
                        self.delegate?.didFinishFetch(feedback: data)
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
            })
        }
    }
}
