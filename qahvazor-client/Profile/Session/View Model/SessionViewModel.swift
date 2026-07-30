//
//  SessionViewModel.swift
//  qahvazor-client
//

import Foundation

struct UserDeviceSession: Decodable, Equatable {
    let id: Int
    let deviceName: String?
    let platform: String?
    let appVersion: String?
    let ip: String?
    let lastActiveAt: Int
    let createdAt: Int
}

protocol SessionViewModelProtocol: ViewModelProtocol {
    func didFinishFetch(sessions: [UserDeviceSession])
    func didFinishRevoke(sessionID: Int)
    func didFinishSessionRequest()
}

final class SessionViewModel {
    weak var delegate: SessionViewModelProtocol?

    func getSessions(showsLoader: Bool = true) {
        if showsLoader {
            delegate?.showActivityIndicator()
        }

        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(
                url: EndPoints.devices.rawValue,
                requestMethod: .get
            ) { [weak self] result in
                guard let self else { return }

                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error, message))
                case .Success(let json):
                    do {
                        let response = try CustomDecoder().decode(
                            JSONData<[UserDeviceSession]>.self,
                            from: json
                        )
                        self.delegate?.didFinishFetch(sessions: response.data ?? [])
                    } catch {
                        self.delegate?.showAlertClosure(error: (APIError.invalidData, nil))
                    }
                }

                if showsLoader {
                    self.delegate?.hideActivityIndicator()
                }
                self.delegate?.didFinishSessionRequest()
            }
        }
    }

    func revokeSession(id: Int) {
        delegate?.showActivityIndicator()

        Task { [weak self] in
            await JSONDownloader.shared.jsonTask(
                url: EndPoints.devices.rawValue + "/\(id)",
                requestMethod: .delete
            ) { [weak self] result in
                guard let self else { return }

                switch result {
                case .Error(let error, let message):
                    self.delegate?.showAlertClosure(error: (error, message))
                case .Success(_):
                    self.delegate?.didFinishRevoke(sessionID: id)
                }

                self.delegate?.hideActivityIndicator()
                self.delegate?.didFinishSessionRequest()
            }
        }
    }
}

extension String {
    var nilIfBlank: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}
