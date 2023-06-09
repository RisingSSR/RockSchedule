//
//  Key.swift
//  CyxbsMobileSwift
//
//  Created by SSR on 2023/5/11.
//

import Foundation
import WCDBSwift

// MARK: Key

public struct Key: Codable {
    
    public enum Kind: String, Codable {
        
        case student = "student"
        
        case teacher = "teacher"
        
        case custom = "custom"
    }
    
    public struct Service: OptionSet, Codable {
        
        static let cache = Service(rawValue: 1 << 0)
        
        static let WK = Service(rawValue: 1 << 1)
        
        static let EK = Service(rawValue: 1 << 2)
        
        static let UN = Service(rawValue: 1 << 3)
        
        static let all: Service = [.cache, .WK, .EK, .UN]
        
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public let sno: String
    public let type: Kind
    
    public private(set) var start: Date?
    public var recentRequest: Date
    
    public var service: Service
    
    public init(sno: String, type: Kind) {
        self.sno = sno
        self.type = type
        recentRequest = Date()
        service = []
    }
    
    public mutating func setEXP(nowWeek: Int) {
        let calendar = Calendar(identifier: .republicOfChina)
        guard let openingWeek = calendar.date(byAdding: .weekOfYear, value: -nowWeek, to: Date()) else { return }
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear, .weekday], from: openingWeek)
        components.weekday = 3
        start = calendar.date(from: components)
    }
    
    public mutating func union(service: Key.Service) {
        self.service = service.union(service)
    }
}

// MARK: ex CustomDebugStringConvertible
extension Key: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(type.rawValue)\(sno)"
    }
}

// MARK: ex Hashable
extension Key: Hashable {
    public var hashValue: Int {
        (sno + type.rawValue).hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(sno)
        hasher.combine(type)
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.sno == rhs.sno && lhs.type == rhs.type
    }
}

// MARK: ex TableCodable
extension Key: TableCodable {
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = Key
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case sno
        case type
        
        case start
        case recentRequest
       
        case service
    }
}

// MARK: CombineItem

public class CombineItem {
    
    public let key: Key
    public private(set) var values: [Course]
    
    public init(key: Key, values: [Course] = []) {
        self.key = key
        self.values = values
    }
}

// MARK: ex CombineItem: CustomDebugStringConvertible

extension CombineItem: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(key.debugDescription) - \(values.count)"
    }
}
