//
//  MainViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 26/12/24.
//

import UIKit

protocol MainViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: [Shop])
}

final class MainViewModel {
    // MARK: - Attributes
    weak var delegate: MainViewModelProtocol?
    
    // MARK: - Network call
    func getList(long: Double, lat: Double) {
        let param: [String : Any ] = [
            Parameters.long.rawValue : long,
            Parameters.lat.rawValue : lat
        ]
        
        JSONDownloader.shared.jsonTask(url: EndPoints.nearShops.rawValue, requestMethod: .get, parameters: param, completionHandler: { [weak self]  (result) in
            guard let self = self else { return }
            switch result {
            case .Error(let error, let message):
                self.delegate?.showAlertClosure(error: (error,message))
            case .Success(let json):
                do {
                    let fetchedData = try CustomDecoder().decode(JSONData<[Shop]>.self, from: json)
                    guard let data = fetchedData.data else { return }
                    self.delegate?.didFinishFetch(data: data)
                } catch {
                    self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                }
            }
        })
    }
}


