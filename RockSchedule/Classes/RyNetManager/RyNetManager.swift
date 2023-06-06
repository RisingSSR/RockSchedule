//
//  RyNetManager.swift
//  CyxbsMobileSwift
//
//  Created by SSR on 2023/5/22.
//

import Alamofire
import SwiftyJSON

public final class RyNetManager {
    
    // MARK: Properties
    
    public static let shared = RyNetManager()
    
    public private(set) var baseURL: String
    
    private init() {
    #if DEBUG
        baseURL = "https://debug.example.com"
    #else
        baseURL = "https://release.example.com"
    #endif
    }
    
    private var serverErrorRequestCount = 0
    private let serverErrorRequestLimit = 3
    private let synchronizationQueue = DispatchQueue(label: "RyNetManager.synchronizationQueue", attributes: .concurrent)
    private var isSerial = true
    
    // MARK: Public Methods
    
    public func request(_ url: String, method: HTTPMethod, parameters: [String: Any]? = nil, headers: HTTPHeaders? = nil, completion: @escaping (AFResult<JSON>) -> Void) {
        let requestURL = baseURL + url
        AF.request(requestURL, method: method, parameters: parameters, headers: headers).responseData { [weak self] response in
            self?.handleResponse(response, url: url, method: method, parameters: parameters, headers: headers, completion: completion)
        }
    }
    
    // MARK: Private Methods
    
    private func handleResponse(_ response: AFDataResponse<Data>, url: String, method: HTTPMethod, parameters: [String: Any]?, headers: HTTPHeaders?, completion: @escaping (AFResult<JSON>) -> Void) {
        switch response.result {
        case .success(let data):
            if let json = try? JSON(data: data) {
                completion(.success(json))
            } else {
                let error = NSError(domain: "JSONError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])
                completion(.failure(.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))))
            }
        case .failure(let error):
            if let statusCode = response.response?.statusCode, (500..<600).contains(statusCode) {
                synchronizationQueue.async(flags: .barrier) { [weak self] in
                    self?.serverErrorRequestCount += 1
                    if self?.serverErrorRequestCount ?? 0 >= self?.serverErrorRequestLimit ?? 0 {
                        self?.serverErrorRequestCount = 0
                        self?.getCurrentBaseURL { newBaseURL in
                            self?.baseURL = newBaseURL
                            AF.request(self?.baseURL ?? "", method: .get).response { response in
                                if let data = response.data {
                                    if let json = try? JSON(data: data) {
                                        completion(.success(json))
                                    } else {
                                        let error = NSError(domain: "JSONError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])
                                        completion(.failure(.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))))
                                    }
                                } else if let error = response.error {
                                    completion(.failure(error))
                                } else {
                                    let error = NSError(domain: "NetworkError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown network error"])
                                    completion(.failure(.responseValidationFailed(reason: .customValidationFailed(error: error))))
                                }
                            }
                        }
                    }
                }
            }
            completion(.failure(error))
        }
    }

    private func getCurrentBaseURL(completion: @escaping (String) -> Void) {
        AF.request("https://be-prod.redrock.team/cloud-manager/check").response { response in
            if let data = response.data, let json = try? JSON(data: data) {
                let baseURL = json["data"]["base_url"].stringValue
                completion(baseURL)
            }
        }
    }
    
    // MARK: Thread Handling
    
    public func setSerial(isSerial: Bool) {
        synchronizationQueue.async(flags: .barrier) { [weak self] in
            self?.isSerial = isSerial
        }
    }
    
    public func requestConcurrently(_ url: String, method: HTTPMethod, parameters: [String: Any]? = nil, headers: HTTPHeaders? = nil, completion: @escaping (AFResult<JSON>) -> Void) {
        DispatchQueue.global().async {
            self.request(url, method: method, parameters: parameters, headers: headers, completion: completion)
        }
    }
}

@available(iOS 13.0, *)
extension RyNetManager {
    
    public func requestConcurrently(_ url: String, method: HTTPMethod, parameters: [String: Any]? = nil, headers: HTTPHeaders? = nil) async -> JSON? {
        try? await withUnsafeThrowingContinuation { continuation in
            self.request(url, method: method) { response in
                switch response {
                case .success(let json):
                    continuation.resume(returning: json)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
