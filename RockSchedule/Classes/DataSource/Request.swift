//
//  Request.swift
//  CyxbsMobileSwift
//
//  Created by SSR on 2023/5/22.
//

import Foundation
import Alamofire

public struct Request {
        
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
    
    public static let shared = Request()
    
    private init() { }
    
    public var limited: TimeInterval = 45 * 60 * 60
    
    // MARK: Imm request
    
    public func policy(request keys: Set<Key>, response: @escaping (AFResult<CombineItem>) -> Void) {
        let date = Date()
        for key in keys {
            if key.type == .custom {
                Request.requesCustom(key: key, disk: true) { response(.success($0)) }
                continue
            }
            let diskKey = Cache.shared.diskKey(for: .compare(key)) ?? key
            var diskItem = Cache.shared.diskItem(for: .compare(diskKey))
            if diskItem == nil, diskKey.service.contains(.cache) {
                diskItem = Cache.memItem(for: .compare(diskKey))
            }
            if let diskItem, let start = key.start, start.timeIntervalSince(date) <= limited {
                response(.success(diskItem))
                continue
            }
            let attribute: Attribute = (key.type == .student ? .dataRequest(.student(key.sno)) : .dataRequest(.teacher(key.sno)))
            Request.request(attribute: attribute) { result in
                if case let .success(item) = result {
                    item.union(service: key.service)
                    response(.success(item))
                } else {
                    response(result)
                }
            }
        }
    }
    
    // MARK: Static request
    
    public static func request(attribute atr: Attribute, response: @escaping (AFResult<CombineItem>) -> Void) {
        switch atr {
        case .dataRequest(let dataRequest):
            RyNetManager.shared.request(dataRequest.URL, method: .post, parameters: dataRequest.parameter) { result in
                switch result {
                case .success(let json):
                    let sno = json["stuNum"].stringValue
                    var key = Key(sno: sno, type: .student)
                    key.setEXP(nowWeek: json["nowWeek"].intValue)
                    
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
            fatalError("TODO: \(string) 自定义还没写")
            break
        }
    }
    
    public static func request(attributes atrs: Set<Attribute>, response: @escaping ([AFResult<CombineItem>]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var results = [AFResult<CombineItem>]()
        
        for attribute in atrs {
            dispatchGroup.enter()
            Request.request(attribute: attribute) { result in
                switch result {
                case .success(let item):
                    results.append(.success(item))
                case .failure(let error):
                    results.append(.failure(error))
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.global(qos: .userInitiated)) {
            DispatchQueue.main.async {
                response(results)
            }
        }
    }
}

public extension Request {
    /// - key: 如果有key，则根据key去创建或取出，如果没有，则去cache问，如果还没有，则创建临时key
    /// - item: 如果取出item则返回，取不出则创建
    static func requesCustom(key: Key? = nil, disk: Bool = false, response: @escaping (CombineItem) -> Void) {
        var key = key
        if key == nil {
            if disk { key = Cache.shared.diskKey(for: .keyName(.custom)) }
            if key == nil { key = Cache.memKey(for: .keyName(.custom)) }
        }
        if key == nil { key = Key(sno: "RedRock_\(Date().timeIntervalSince1970)", type: .custom) }
        guard let key else { return }
        
        var item: CombineItem? = nil
        if disk { item = Cache.shared.diskItem(for: .compare(key)) }
        if item == nil { item = Cache.memItem(for: .compare(key)) }
        if item == nil {
            item = CombineItem(key: key)
            if disk { Cache.shared.disk(cache: item!) }
            Cache.mem(cache: item!)
        }
        if let item { response(item) }
    }
}

extension Request.Attribute.DataRequest: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .student(let sno):
            hasher.combine(sno)
            hasher.combine("student")
        case .teacher(let sno):
            hasher.combine(sno)
            hasher.combine("teacher")
        }
    }
    
    public static func == (lhs: Request.Attribute.DataRequest, rhs: Request.Attribute.DataRequest) -> Bool {
        switch (lhs, rhs) {
        case (.student(let lhsSno), .student(let rhsSno)):
            return lhsSno == rhsSno
        case (.teacher(let lhsSno), .teacher(let rhsSno)):
            return lhsSno == rhsSno
        default:
            return false
        }
    }
}

extension Request.Attribute: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .dataRequest(let request):
            hasher.combine(request.URL)
            hasher.combine(request.parameter)
        case .custom(let string):
            hasher.combine(string)
        }
    }
    
    public static func == (lhs: Request.Attribute, rhs: Request.Attribute) -> Bool {
        switch (lhs, rhs) {
        case (.dataRequest(let lhsRequest), .dataRequest(let rhsRequest)):
            return lhsRequest == rhsRequest
        case (.custom(let lhsString), .custom(let rhsString)):
            return lhsString == rhsString
        default:
            return false
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
