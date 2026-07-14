//
//  PromocodeViewModel.swift
//  qahvazor-client
//
//  Created by Husan Muhammadsharif on 08/07/26.
//

import UIKit

protocol PromocodeViewModelProtocol: ViewModelProtocol {
    func didFinishCheckPromocode(data: PromocodePreview)
}

final class PromocodeViewModel {
    weak var delegate: PromocodeViewModelProtocol?

    func checkPromocode(code: String, shopId: Int, drinkId: Int, modifiers: [Modification]) async {
        let parameters: [String: Any] = [
            Parameters.code.rawValue: code,
            Parameters.shopId.rawValue: shopId,
            Parameters.drinkId.rawValue: drinkId,
            Parameters.modifiers.rawValue: sortModifiers(modifiers)
        ]

        delegate?.showActivityIndicator()
        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(
                url: EndPoints.checkPromocode.rawValue,
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
                            let fetchedData = try CustomDecoder().decode(JSONData<PromocodePreview>.self, from: json)
                            guard let data = fetchedData.data, data.valid == true else {
                                self.delegate?.showAlertClosure(error: (APIError.fromMessage, fetchedData.message))
                                return
                            }
                            self.delegate?.didFinishCheckPromocode(data: data)
                        } catch {
                            self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                        }
                    }
                }
            )
        }
    }
}

private extension PromocodeViewModel {
    func sortModifiers(_ data: [Modification]) -> [[String: Any]] {
        guard !data.isEmpty else { return [] }

        return data.compactMap { item in
            guard
                let modifierId = item.modificationId,
                let modifierKey = item.modificationKey,
                let modifierPrice = item.modificationPrice
            else {
                return nil
            }

            return [
                Parameters.modifierId.rawValue: modifierId,
                Parameters.modifierKey.rawValue: modifierKey,
                Parameters.modifierPrice.rawValue: modifierPrice,
                Parameters.modifierGroupId.rawValue: item.modificationGroupId ?? ""
            ]
        }
    }
}
