//
//  NotificationsViewModel.swift
//  itv-new
//
//  Created Admin NBU on 13/10/21.

import Foundation
import Alamofire

protocol NotificationsViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(notifications: [NewsNotification], meta: Meta?)
}

final class NotificationsViewModel {
    // MARK: - Attributes
    weak var delegate: NotificationsViewModelProtocol?
    
    // MARK: - Network call
    func notificationsList(page: Int = 1, itemsPerPage: Int = 10) {
        
        let params: [String : String] = [
            Parameters.page.rawValue : String(page),
            Parameters.itemsPerPage.rawValue : String(itemsPerPage)
        ]
        
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: EndPoints.notificationsList.rawValue, requestMethod: .get, parameters: params, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<[NewsNotification]>.self, from: json)
                        guard let data = fetchedData.data else { return }
                        self.delegate?.didFinishFetch(notifications: data, meta: fetchedData.meta)
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
                
            })
        }
        
        
    }
}
