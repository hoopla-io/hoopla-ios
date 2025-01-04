//
//  ProfileViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 25/12/24.
//

import UIKit
import Alamofire
protocol ProfileViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: SignIn)
}

final class ProfileViewModel {
    // MARK: - Attributes
    weak var delegate: ProfileViewModelProtocol?
    
    // MARK: - Network call
    func numberSignIn(number: String) {
        
        let params: [String : String] = [
            Parameters.phoneNumber.rawValue : number
        ]
        
        delegate?.showActivityIndicator()
        JSONDownloader.shared.jsonTask(url: EndPoints.signIn.rawValue, requestMethod: .post, parameters: params, completionHandler: { [weak self]  (result) in
            guard let self = self else { return }
            switch result {
            case .Error(let error, let message):
                self.delegate?.showAlertClosure(error: (error,message))
            case .Success(let json):
                do {
                    let fetchedData = try CustomDecoder().decode(JSONData<SignIn>.self, from: json)
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

