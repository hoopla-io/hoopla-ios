//
//  SearchShopViewModel.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 11/07/26.
//

import Foundation

protocol SearchShopViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(shops: [Shop])
}

final class SearchShopViewModel {
    weak var delegate: SearchShopViewModelProtocol?

    func getShops(partnerId: Int) {
        let parameters: [String: Any] = [
            Parameters.partnerId.rawValue: partnerId,
            Parameters.long.rawValue: Coordinate.longitude,
            Parameters.lat.rawValue: Coordinate.latitude
        ]

        delegate?.showActivityIndicator()
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(
                url: EndPoints.partnersShops.rawValue,
                requestMethod: .get,
                parameters: parameters
            ) { [weak self] result in
                guard let self else { return }
                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error, message))
                case .Success(let json):
                    do {
                        let response = try CustomDecoder().decode(JSONData<[Shop]>.self, from: json)
                        self.delegate?.didFinishFetch(shops: response.data ?? [])
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }
                self.delegate?.hideActivityIndicator()
            }
        }
    }
}
