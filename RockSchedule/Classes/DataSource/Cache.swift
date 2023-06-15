//
//  Cache.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/2.
//

import Foundation
import WCDBSwift

// MARK: Disk

public struct Cache {
    public enum Keyname: Int, Codable {
        case mine = 0
        case custom = 1
        case others = 2
        
        var name: String {
            switch self {
            case .mine: return "mine"
            case .custom: return "custom"
            case .others: return "others"
            }
        }
    }
    
    public enum TouchElement {
        case compare(Key)
        case keyName(Keyname)
    }
    
    public static let shared = Cache()
    
    private var keyCache: Set<Key>
    public private(set) var keyMapTable: [Keyname: Key]
    
    public private(set) var itemCache: LRUCache<Key, CombineItem>
    
    private init() {
        keyMapTable = [:]
        itemCache = LRUCache(countLimit: 10)
        keyCache = Set()
    }
    
    // !!!: Key
    
    public mutating func disk(cache key: Key, for name: Keyname? = nil) {
        if let name { keyMapTable[name] = key }
        keyCache.insert(key)
    }
    
    public func diskKey(for element: TouchElement) -> Key? {
        switch element {
        case .compare(let t):
            guard var value = keyCache.first(where: { $0 == t }) else { return t }
            value.union(service: t.service)
            return value
        case .keyName(let keyname):
            return keyMapTable[keyname]
        }
    }
    
    // !!!: Item
    
    public mutating func disk(cache item: CombineItem, for name: Keyname? = nil) {
        disk(cache: item.key, for: name)
        itemCache.setValue(item, forKey: item.key)
    }
    
    public func diskItem(for element: TouchElement) -> CombineItem? {
        guard let key = diskKey(for: element) else { return nil }
        return itemCache.value(forKey: key)
    }
}

extension Cache.Keyname: Comparable {
    public static func == (lhs: Cache.Keyname, rhs: Cache.Keyname) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
    public static func < (lhs: Cache.Keyname, rhs: Cache.Keyname) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: Mem

public extension Cache {
    static var appGroup: String?
    static var fileStr: String {
        var str: String?
        if let appGroup {
            str = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?.path
        }
        if str == nil {
            str = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        }
        return str!
    }
    static var userDefaults: UserDefaults {
        UserDefaults(suiteName: appGroup) ?? .standard
    }
    
    static let db: Database = {
        let db = Database(withPath: fileStr.appending("/schedule_WCDB"))
        try? db.create(table: "key", of: Key.self)
        return db
    }()
    
    // !!!: Key
    
    static func mem(cache key: Key, for name: Keyname? = nil) {
        if let name {
            userDefaults.set(key, forKey: name.name)
        }
        try? db.run(transaction: {
            try? db.delete(fromTable: "key", where: Key.Properties.sno == key.sno
                           && Key.Properties.type.rawValue == key.type.rawValue)
            try? db.insert(objects: key, intoTable: "key")
        })
    }
    
    static func memKey(for element: TouchElement) -> Key? {
        switch element {
        case .compare(var t):
            let res: Key? = try? db.getObject(on: Key.Properties.all, fromTable: "key")
            if let res { t.union(service: res.service) }
            return t
        case .keyName(let keyname):
            var res = userDefaults.object(forKey: keyname.name) as? Key
            let cache: Key? = try? db.getObject(on: Key.Properties.all, fromTable: "key")
            res = res ?? cache
            if let cache { res?.union(service: cache.service) }
            return res
        }
    }
    
    // !!!: Item
    
    static func mem(cache item: CombineItem, for name: Keyname? = nil) {
        mem(cache: item.key, for: name)
        if let t = try? db.isTableExists(item.key.keyName), !t {
            try? db.create(table: item.key.keyName, of: Course.self)
        }
        try? db.run(transaction: {
            try? db.delete(fromTable: item.key.keyName)
            try? db.insert(objects: item.values, intoTable: item.key.keyName)
        })
    }
    
    static func memItem(for element: TouchElement) -> CombineItem? {
        guard let key = memKey(for: element) else { return nil }
        guard let values: [Course] = try? db.getObjects(on: Course.Properties.all, fromTable: key.keyName) else { return nil }
        return CombineItem(key: key, values: values)
    }
}
