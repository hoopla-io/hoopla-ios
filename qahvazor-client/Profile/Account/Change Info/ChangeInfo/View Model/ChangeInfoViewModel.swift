//
//  ChangeInfoViewModel.swift
//  itv-new
//
//  Created Admin NBU on 13/10/21.

import Foundation

protocol ChangeInfoViewModelProtocol: ViewModelProtocol {
    func didFinishFetch()
}

final class ChangeInfoViewModel {
    // MARK: - Attributes
    weak var delegate: ChangeInfoViewModelProtocol?
    
    // MARK: - Network call
    func updateMe(name: String, gender: String? = nil, dateOfBirth: Int? = nil) {
        var params: [String : String] = [
            Parameters.name.rawValue : name
        ]
        if let gender {
            params[Parameters.gender.rawValue] = gender
        }
        if let dateOfBirth {
            let dateOfBirthString = DateFormatter.string(timestamp: dateOfBirth, formatter: .birthDate)
            params[Parameters.dateOfBirth.rawValue] = dateOfBirthString
        }
        delegate?.showActivityIndicator()
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: EndPoints.updateMe.rawValue, requestMethod: .put, parameters: params, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(_):
                    self.delegate?.didFinishFetch()
                }
                self.delegate?.hideActivityIndicator()
            })
        }
    }
}
