//
//  Request.swift
//  CyxbsMobileSwift
//
//  Created by SSR on 2023/5/22.
//

import Foundation
import Alamofire
import SwiftyJSON

public struct Request {
    
    private static let queue = DispatchQueue(label: "redrock.kebiao")
    
    public enum Attribute: Codable {
        public enum DataRequest: Codable {
            case student(String)
            case teacher(String)
        }
        case dataRequest(DataRequest)
        case custom(String)
    }
    
    public static func dataRequest(attribute atr: Attribute.DataRequest) -> DataRequest {
        switch atr {
        case .student(let string):
            return AF.request("https://be-prod.redrock.cqupt.edu.cn" + "/magipoke-jwzx/kebiao", method: .post, parameters: ["stu_num" : string])
        case .teacher(let string):
            return AF.request("https://be-prod.redrock.cqupt.edu.cn" + "/magipoke-teakb/api/teaKb", method: .post, parameters: ["tea" : string])
        }
    }
    
    public static func request(attribute atr: Attribute, response: @escaping (CombineItem) -> Void) {
//        queue.async {
            switch atr {
            case .dataRequest(let dataRequest):
                self.dataRequest(attribute: dataRequest).responseDecodable(of: JSON.self) { responseValue in
                    if let data = responseValue.data {
                        let json = JSON(data)
                        
                        let sno = json["stuNum"].stringValue
                        let key = Key(sno: sno, type: .student)
                        
                        var courseAry = [Course]()
                        for eachJson in json["data"].arrayValue {
                            courseAry.append(Course.json(from: eachJson))
                        }
                        
                        let item = CombineItem(key: key, values: courseAry)
                        response(item)
                    } else {
                        if let error = responseValue.error {
                            // MARK: TODO
                            fatalError("TODO: Plase do something with \(error)")
                        }
                    }
                }
            case .custom(_):
                break
            }
//        }
    }
}

@available (iOS 13.0, *)
public extension Request {
    static func request(attribute atr: Attribute) async throws -> CombineItem? {
        try await withUnsafeThrowingContinuation({ continuation in
            request(attribute: atr) { response in
                continuation.resume(returning: response)
            }
        })
    }
}
