//
//  SearchViewModel.swift
//  qahvazor-client
//
//  Created by Alphazet on 22/01/25.
//

import UIKit

protocol SearchViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(partners: [Company])
}

final class SearchViewModel {
    // MARK: - Attributes
    weak var delegate: SearchViewModelProtocol?

    func getPartners() {
        performRequest(
            url: EndPoints.partnersList.rawValue,
            parameters: nil,
            type: Company.self
        ) { [weak self] partners in
            self?.delegate?.didFinishFetch(partners: partners)
        }
    }
    
    private func performRequest<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        type: T.Type,
        completion: @escaping ([T]) -> Void
    ) {
        delegate?.showActivityIndicator()
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(url: url, requestMethod: .get, parameters: parameters, completionHandler: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error,message))
                case .Success(let json):
                    do {
                        let fetchedData = try CustomDecoder().decode(JSONData<[T]>.self, from: json)
                        completion(fetchedData.data ?? [])
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
                self.delegate?.hideActivityIndicator()
            })
        }
    }
}
