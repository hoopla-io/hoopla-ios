//
//  ReviewViewModel.swift
//  qahvazor-client
//
//  Created by iOS on 25/03/26.
//

import UIKit

protocol ReviewViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(data: [OrderHistory], meta: Meta?)
}

final class ReviewViewModel {
    // MARK: - Attributes
    weak var delegate: ReviewViewModelProtocol?
    
    // MARK: - Network call
    func sendFeedback(id: Int, rating: Int, comment: String) {
        let feedback = "/feedback"
        let url = "\(EndPoints.orders.rawValue)/\(id)"
        let params: [String : String] = [
            Parameters.rating.rawValue : String(rating),
            Parameters.comment.rawValue : comment
        ]
        delegate?.showActivityIndicator()
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: url + feedback, requestMethod: .post, parameters: params, completionHandler: { [weak self]  (result) in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<OrderHistory>.self, from: json)
//                        self.delegate?.didFinishFetch(data: fetchedData.data)
                    } catch {
                        print("❌ JSON Decoding Error: \(error)")
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
                self.delegate?.hideActivityIndicator()
            })
        }
    }
    
}
