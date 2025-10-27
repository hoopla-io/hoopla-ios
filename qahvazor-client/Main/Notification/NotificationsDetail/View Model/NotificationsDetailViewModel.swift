//
//  NotificationsDetailViewModel.swift
//  itv-new
//
//  Created Admin NBU on 14/10/21.

import Foundation

protocol NotificationsDetailViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(notification: NewsNotification)
}

final class NotificationsDetailViewModel {
    // MARK: - Attributes
    weak var delegate: NotificationsDetailViewModelProtocol?
    
    // MARK: - Network call
    internal func notificationsShow(notificationId: Int) {
        
        let params: [String : String] = [
            Parameters.notificationId.rawValue : String(notificationId)
        ]
        
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: EndPoints.notificationShow.rawValue, requestMethod: .get, parameters: params, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<NewsNotification>.self, from: json)
                        guard let data = fetchedData.data else { return }
                        self.delegate?.didFinishFetch(notification: data)
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
            })
        }
    }
}
