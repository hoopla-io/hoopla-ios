//
//  GiftcardViewModel.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 11/07/26.
//

import UIKit

protocol GiftcardViewModelProtocol: ViewModelProtocol {
    func didFinishRedeem(data: GiftcardRedemption)
}

final class GiftcardViewModel {
    weak var delegate: GiftcardViewModelProtocol?

    func redeem(code: String) async {
        let parameters: [String: Any] = [
            Parameters.code.rawValue: code
        ]

        delegate?.showActivityIndicator()

        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(
                url: EndPoints.redeemGiftcard.rawValue,
                requestMethod: .post,
                parameters: parameters,
                completionHandler: { [weak self] result in
                    guard let self else { return }
                    defer {
                        self.delegate?.hideActivityIndicator()
                    }

                    switch result {
                    case .Error(let error, let message):
                        self.delegate?.showAlertClosure(error: (error, message))
                    case .Success(let json):
                        do {
                            let response = try CustomDecoder().decode(GiftcardRedeemResponse.self, from: json)
                            guard let data = response.data else {
                                self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                                return
                            }
                            self.delegate?.didFinishRedeem(data: data)
                        } catch {
                            self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                        }
                    }
                }
            )
        }
    }
}
