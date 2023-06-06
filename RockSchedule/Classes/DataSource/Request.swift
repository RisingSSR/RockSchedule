//
//  Request.swift
//  CyxbsMobileSwift
//
//  Created by SSR on 2023/5/22.
//

import Foundation
import Alamofire

public struct Request {
    
    private static let queue = DispatchQueue(label: "redrock.kebiao")
    
    public enum Attribute: Codable {
        public enum DataRequest: Codable {
            case student(String)
            case teacher(String)
            
            public var URL: String {
                switch self {
                case .student(_): return "/magipoke-jwzx/kebiao"
                case .teacher(_): return "/magipoke-teakb/api/teaKb"
                }
            }
            
            public var parameter: [String: String] {
                switch self {
                case .student(let sno): return ["stuNum": sno]
                case .teacher(let sno): return ["tea": sno]
                }
            }
        }
        case dataRequest(DataRequest)
        case custom(String)
    }
    
    public static func request(attribute atr: Attribute, response: @escaping (AFResult<CombineItem>) -> Void) {
        switch atr {
        case .dataRequest(let dataRequest):
            RyNetManager.shared.request(dataRequest.URL, method: .post, parameters: dataRequest.parameter) { result in
                switch result {
                case .success(let json):
                    let sno = json["stuNum"].stringValue
                    let key = Key(sno: sno, type: .student)
                    
                    var courseAry = [Course]()
                    for eachJson in json["data"].arrayValue {
                        courseAry.append(Course.json(from: eachJson))
                    }
                    
                    let item = CombineItem(key: key, values: courseAry)
                    response(.success(item))
                case .failure(let error):
                    response(.failure(error))
                }
            }
        case .custom(let string):
            break
        }
    }
}

@available (iOS 13.0, *)
public extension Request {
    static func request(attribute atr: Attribute) async throws -> AFResult<CombineItem> {
        try await withUnsafeThrowingContinuation { continuation in
            request(attribute: atr) { response in
                continuation.resume(returning: response)
            }
        }
    }
}
