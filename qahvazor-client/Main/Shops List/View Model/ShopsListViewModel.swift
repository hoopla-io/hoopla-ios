//
//  ShopsListViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 26/12/24.
//

import UIKit

protocol ShopsListViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: Company)
}

final class ShopsListViewModel {
    // MARK: - Attributes
    weak var delegate: ShopsListViewModelProtocol?
    
    // MARK: - Network call
    func getList() {
        
        JSONDownloader.shared.jsonTask(url: EndPoints.companyList.rawValue, requestMethod: .get, completionHandler: { [weak self]  (result) in
            guard let self = self else { return }
            switch result {
            case .Error(let error, let message):
                self.delegate?.showAlertClosure(error: (error,message))
            case .Success(let json):
                do {
                    let fetchedData = try CustomDecoder().decode(JSONData<Company>.self, from: json)
                    guard let data = fetchedData.data else { return }
                    self.delegate?.didFinishFetch(data: data)
                } catch {
                    self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                }
            }
        })
    }
    
}


