//
//  PartnerDetailViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 27/12/24.
//

import UIKit

protocol PartnerDetailViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: [Shop])
    func didFinishFetch(data: Company)
}

final class PartnerDetailViewModel {
    // MARK: - Attributes
    weak var delegate: PartnerDetailViewModelProtocol?
    
    // MARK: - Network call
    func getFilialsList(partnerId: Int) {
        let params: [String : Any] = [
            Parameters.partnerId.rawValue : partnerId
        ]
        
        JSONDownloader.shared.jsonTask(url: EndPoints.partnerShops.rawValue, requestMethod: .get, parameters: params, completionHandler: { [weak self]  (result) in
            guard let self = self else { return }
            switch result {
            case .Error(let error, let message):
                self.delegate?.showAlertClosure(error: (error,message))
            case .Success(let json):
                do {
                    let fetchedData = try CustomDecoder().decode(JSONData<[Shop]>.self, from: json)
                    guard let data = fetchedData.data else { self.delegate?.didFinishFetch(data: [Shop]())
                        return }
                    self.delegate?.didFinishFetch(data: data)
                } catch {
                    self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                }
            }
        })
    }
    
    func getPartnerInfo(id: Int) {
        let params: [String : Any] = [
            Parameters.id.rawValue : id
        ]
        
        JSONDownloader.shared.jsonTask(url: EndPoints.partner.rawValue, requestMethod: .get, parameters: params, completionHandler: { [weak self]  (result) in
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



