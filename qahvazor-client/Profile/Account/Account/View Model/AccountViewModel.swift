//
//  AccountViewModel.swift
//  itv-new
//
//  Created Admin NBU on 13/10/21.

import Foundation

protocol AccountViewModelProtocol: ViewModelProtocol {
    func didFinishFetchAcc(data: Account)
}

final class AccountViewModel {
    // MARK: - Attributes
    weak var delegate: AccountViewModelProtocol?
    
    // MARK: - Network call
    func editMe() {
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: EndPoints.editMe.rawValue, requestMethod: .get, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<Account>.self, from: json)
                        guard let data = fetchedData.data else { return }
                        self.delegate?.didFinishFetchAcc(data: data)
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
            })
        }
    }
    
}
