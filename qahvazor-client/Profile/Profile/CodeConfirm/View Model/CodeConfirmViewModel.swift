//
//  CodeConfirmViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 25/12/24.
//

import Foundation

protocol CodeConfirmViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: Tokens)
    func didFinishFetchResend(data: SignIn)
}

final class CodeConfirmViewModel {
    // MARK: - Attributes
    weak var delegate: CodeConfirmViewModelProtocol?
    
    // MARK: - Network call
    func smsConfirm(sessionId: String, code: String) {
        
//        let params: [String : String] = [
//            Parameters.sessionId.rawValue : sessionId,
//            Parameters.code.rawValue : code,
//            Parameters.firebaseToken.rawValue : UserDefaults.standard.firebaseToken() ?? ""
//        ]
        
        delegate?.showActivityIndicator()
//        JSONDownloader.shared.jsonTask(baseUrl: .auth, path: .pathV1, url: EndPoints.confirmSms.rawValue, requestMethod: .post, parameters: params, completionHandler: { [weak self]  (result) in
//            guard let self = self else { return }
//            switch result {
//            case .Error(let error, let message):
//                self.delegate?.showAlertClosure(error: (error,message))
//            case .Success(let json):
//                do {
//                    let fetchedData = try CustomDecoder().decode(JSONData<Tokens>.self, from: json)
//                    guard let data = fetchedData.data else { return }
//                    self.delegate?.didFinishFetch(data: data)
//                } catch {
//                    self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
//                }
//            }
//            self.delegate?.hideActivityIndicator()
//        })
    }
    
    func resendSms(sessionId: String) {
        
//        let params: [String : String] = [
//            Parameters.sessionId.rawValue : sessionId
//        ]
//        
//        delegate?.showActivityIndicator()
//        JSONDownloader.shared.jsonTask(baseUrl: .auth, path: .pathV1, url: EndPoints.resendSms.rawValue, requestMethod: .post, parameters: params, completionHandler: { [weak self]  (result) in
//            guard let self = self else { return }
//            switch result {
//            case .Error(let error, let message):
//                self.delegate?.showAlertClosure(error: (error,message))
//            case .Success(let json):
//                do {
//                    let fetchedData = try CustomDecoder().decode(JSONData<SignIn>.self, from: json)
//                    guard let data = fetchedData.data else { return }
//                    self.delegate?.didFinishFetchResend(data: data)
//                } catch {
//                    self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
//                }
//            }
//            self.delegate?.hideActivityIndicator()
//        })
    }
}
