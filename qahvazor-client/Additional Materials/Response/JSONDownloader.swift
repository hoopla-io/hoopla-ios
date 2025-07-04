//
//  JSONDownloader.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import UIKit
import DeviceKit
import Alamofire

enum VersionError: Error {
    case invalidResponse, invalidBundleInfo
}

enum StatusCode: Int {
    case success200 = 200
    case success202 = 202
    case notAuthorized = 401
    case serverError = 500
    case tokenError = 412
    case notEnoughBalance = 428
    case needSubscription = 402
}

typealias JSONTaskCompletionHandler = (Result<Data>) -> ()

class JSONDownloader {
    
    private init() {}
    
    static let shared = JSONDownloader()
    
    private let iDevice = UIDevice.current.identifierForVendor?.uuidString ?? ""
    private let iVersion = Bundle.main.releaseVersionNumber ?? "0"
    private let devType: String = {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return Headers.phone.rawValue
        case .pad:
            return Headers.pad.rawValue
        default:
            return ""
        }
    }()
    
    private let isDebug = true
    
    let retryLimit = 3
    
    let retryDelay: TimeInterval = 1
    
    var isRetrying = false
    
    func jsonTask(baseUrl: MainConstants = .host, api: MainConstants = .api , path: MainConstants = .path1, url: String, query: String? = nil, requestMethod: HTTPMethod, parameters: [String : Any]? = nil, completionHandler completion: @escaping JSONTaskCompletionHandler) {
        
        // Set Components
        var components = URLComponents()
        components.scheme = MainConstants.scheme.rawValue
        components.host   = baseUrl.rawValue
        components.path   = api.rawValue + path.rawValue + url
        if let query {
            components.query = query
        }
        // Set QueryItems
        if requestMethod == .get {
            components.setQueryParameters(parameters)
        }
        
        guard let URL = components.url else { return }
        
        var headers: HTTPHeaders = []
        // Set Headers
        headers.add(name: Headers.contentType.rawValue, value: Headers.applicationJson.rawValue)
        headers.add(name: Headers.AUTHORIZATION.rawValue, value: "Bearer " + (UserDefaults.standard.accessToken() ?? ""))
        
        let params: [String: Any]? = requestMethod == .get ? nil : parameters
        var encoding: ParameterEncoding
        if requestMethod == .get {
            encoding = URLEncoding.default
        } else {
            encoding = JSONEncoding.default
        }
        
        AF.request(URL, method: requestMethod, parameters: params, encoding: encoding, headers: headers, interceptor: self).customValidate().responseData { result in
            DispatchQueue.main.async {
                guard let httpResponse = result.response else {
                    completion(.Error(.requestFailed))
                    return
                }
                
                guard let data = result.data else {
                    completion(.Error(.invalidData))
                    return
                }
                
                if self.isDebug {
                    print("\n--- Start debug ---")
                    print("URL: \(URL)")
//                    print("Headers: \(String(describing: headers.dictionary))")
                    print("Parameters: \(String(describing: parameters))")
                    print("HTTPMethod: \(String(describing: requestMethod.rawValue))")
                    print("Status Code: \(httpResponse.statusCode)")
                }
                
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                    if self.isDebug {
                        print("Result: \(String(describing: jsonResult))")
                    }
                    
                    switch httpResponse.statusCode {
                    case StatusCode.success200.rawValue, StatusCode.success202.rawValue:
                        completion(.Success(data))
                    case StatusCode.notAuthorized.rawValue:
                        UserDefaults.standard.removeAccount()
                        completion(.Error(.notAuthorized))
                    case StatusCode.notEnoughBalance.rawValue, StatusCode.needSubscription.rawValue:
                        completion(.Success(data))
                    case StatusCode.serverError.rawValue:
                        completion(.Error(.serverError, jsonResult?["message"] as? String))
                    default:
                        completion(.Error(.fromMessage, jsonResult?["message"] as? String))
                    }
                } catch {
                    completion(.Error(.responseUnsuccessful))
                }
                
                if self.isDebug {
                    print("--- End debug ---\n")
                }
            }
        }
    }
    
}

extension JSONDownloader: RequestRetrier, RequestAdapter, RequestInterceptor {
    
    func retry(_ request: Alamofire.Request, for session: Alamofire.Session, dueTo error: Error, completion: @escaping (Alamofire.RetryResult) -> Void) {
        let response = request.task?.response as? HTTPURLResponse
        if NetworkReachabilityManager()?.isReachable ?? false {//refresh token
            if request.retryCount < self.retryLimit, UserDefaults.standard.isAuthed() {
                if let statusCode = response?.statusCode, statusCode == StatusCode.tokenError.rawValue, !isRetrying {
                    self.isRetrying = true
                    self.determineError(error: error, completion: completion)
                } else {
                    completion(.retryWithDelay(self.retryDelay))
                }
            } else {
                completion(.doNotRetry)
            }
        } else {//no internet
            completion(.retryWithDelay(self.retryDelay))
        }
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Alamofire.Session, completion: @escaping (Swift.Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        guard let token = UserDefaults.standard.accessToken() else {
            completion(.success(urlRequest))
            return
        }
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: Headers.AUTHORIZATION.rawValue)
        
        completion(.success(urlRequest))
    }
    
    private func determineError(error: Error, completion: @escaping (RetryResult) -> Void) {
        if let afError = error as? AFError {
            switch afError {
            case .responseValidationFailed(let reason):
                self.determineResponseValidationFailed(reason: reason, completion: completion)
            default:
                self.isRetrying = false
                completion(.retryWithDelay(self.retryDelay))
            }
        }
    }
    
    private func determineResponseValidationFailed(reason: AFError.ResponseValidationFailureReason, completion: @escaping (RetryResult) -> Void) {
        switch reason {
        case .unacceptableStatusCode(let code):
            switch code {
            case StatusCode.tokenError.rawValue:
                refreshToken { [weak self] statusCode in
                    guard let self else { return }
                    if statusCode == StatusCode.success200.rawValue {
                        self.isRetrying = false
                        completion(.retryWithDelay(self.retryDelay))
                    } else if statusCode == StatusCode.notAuthorized.rawValue {
                        self.isRetrying = false
                        UserDefaults.standard.removeAccount()
                        UIViewController().resetTabBar(4)
                        completion(.doNotRetry)
                    } else {
                        self.isRetrying = false
                        completion(.retryWithDelay(self.retryDelay))
                    }
                }
            default:
                self.isRetrying = false
                completion(.doNotRetry)
            }
        default:
            self.isRetrying = false
            completion(.retryWithDelay(self.retryDelay))
        }
    }
    
    func refreshToken(completion: @escaping (_ StatusCode: Int) -> Void) {
        let url = EndPoints.refreshToken.rawValue
        let refreshToken = Parameters.refreshToken.rawValue + Symbols.equal.rawValue + (UserDefaults.standard.refreshToken() ?? "")
//        let firebaseToken = Parameters.firebaseToken.rawValue + Symbols.equal.rawValue + (UserDefaults.standard.firebaseToken() ?? "")
        let query = refreshToken// + Symbols.and.rawValue + firebaseToken
        
        // Set Components
        var components = URLComponents()
        components.scheme = MainConstants.scheme.rawValue
        components.host   = MainConstants.host.rawValue
        components.path   = MainConstants.api.rawValue + MainConstants.path1.rawValue + url
        components.query = query
        
        guard let URL = components.url else { return }
        
        var headers: HTTPHeaders = []
        // Set Headers
        headers.add(name: Headers.contentType.rawValue, value: Headers.applicationJson.rawValue)
        headers.add(name: Headers.AUTHORIZATION.rawValue, value: "Bearer " + (UserDefaults.standard.accessToken() ?? ""))
        
        AF.request(URL, method: .patch, encoding: JSONEncoding.default, headers: headers).response(completionHandler: { result in
            DispatchQueue.main.async {
                guard let httpResponse = result.response else {
                    completion(StatusCode.serverError.rawValue)
                    return
                }
                
                guard let data = result.data else {
                    completion(StatusCode.serverError.rawValue)
                    return
                }
                
                if self.isDebug {
                    print("\n--- Start debug ---")
                    print("URL: \(URL)")
                    print("Headers: \(String(describing: headers.dictionary))")
                    print("Status Code: \(httpResponse.statusCode)")
                }
                
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
                    if self.isDebug {
                        print("Result: \(String(describing: jsonResult))")
                    }
                    
                    switch httpResponse.statusCode {
                    case StatusCode.success200.rawValue, StatusCode.success202.rawValue:
                        let fetchedData = try CustomDecoder().decode(JSONData<Tokens>.self, from: data)
                        guard let data = fetchedData.data else { return }
                        UserDefaults.standard.saveTokens(data: data)
                        completion(StatusCode.success200.rawValue)
                    case StatusCode.notAuthorized.rawValue:
                        completion(StatusCode.notAuthorized.rawValue)
                    default:
                        completion(StatusCode.serverError.rawValue)
                    }
                } catch {
                    completion(StatusCode.serverError.rawValue)
                }
                
                if self.isDebug {
                    print("--- End debug ---\n")
                }
            }
        })
    }
    
}

extension DataRequest {
    func customValidate() -> Self {
        return self.validate { request, response, data -> Request.ValidationResult in
            let statusCode = response.statusCode
            if statusCode != StatusCode.tokenError.rawValue {
                return .success(())
            } else {
                let authenticationAction = self.getAuthenticationAction(request?.url?.absoluteString ?? "", statusCode: statusCode, data: data)
                return .failure(AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: authenticationAction.rawValue)))
            }
        }
    }
    
    private func getAuthenticationAction(_ endpoint: String? = "", statusCode: Int, data: Data?) -> StatusCode {
        let authenticationAction = StatusCode(rawValue: statusCode) ?? .serverError
        return authenticationAction
    }
    
}
