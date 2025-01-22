//
//  SearchViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 22/01/25.
//

import UIKit

protocol SearchViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: [Shop]?)
}

final class SearchViewModel {
    // MARK: - Attributes
    weak var delegate: SearchViewModelProtocol?
    
    // MARK: - Network call
    func getList(name: String? = nil) {
        var param: [String : Any ] = [
            Parameters.long.rawValue : Coordinate.longitude,
            Parameters.lat.rawValue : Coordinate.latitude
        ]
        if let name {
            param[Parameters.name.rawValue] = name
        }
        
        delegate?.showActivityIndicator()
        JSONDownloader.shared.jsonTask(url: EndPoints.nearShops.rawValue, requestMethod: .get, parameters: param, completionHandler: { [weak self]  (result) in
            guard let self = self else { return }
            switch result {
            case .Error(let error, let message):
                self.delegate?.showAlertClosure(error: (error,message))
            case .Success(let json):
                do {
                    let fetchedData = try CustomDecoder().decode(JSONData<[Shop]>.self, from: json)
                    self.delegate?.didFinishFetch(data: fetchedData.data)
                } catch {
                    self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                }
            }
            self.delegate?.hideActivityIndicator()
        })
    }
}



