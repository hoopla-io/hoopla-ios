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
        let url = "\(EndPoints.feedbacks.rawValue)/\(id)"
        let params: [String : String] = [
            Parameters.rating.rawValue : String(rating),
            Parameters.comment.rawValue : comment
        ]
        
        Task { [] in
            await JSONDownloader.shared.jsonTask(url: url + feedback, requestMethod: .post, parameters: params, completionHandler: { _ in
            })
        }
    }
    
}
