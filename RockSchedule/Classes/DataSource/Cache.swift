//
//  Cache.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/2.
//

import Foundation
import WCDBSwift

public struct Cache {
    public enum Keyname: String {
        case mine = "mine"
        case reminder = "reminder"
        case other = "other"
    }
    
    public static let shared = Cache()
    
    public private(set) var keyMapTable: [Keyname: Key]
    public private(set) var itemCache: LRUCache<Key, CombineItem>
    private var keyCache: Set<Key>
    
    private init() {
        keyMapTable = [:]
        itemCache = LRUCache(countLimit: 10)
        keyCache = Set()
    }
    
    // !!!: Key
    
    public mutating func disk(cache key: Key, for name: Keyname? = nil) {
        if let name {
            keyMapTable[name] = key
        }
        keyCache.insert(key)
    }
    
    public func diskKey(for key: Key? = nil, keyName name: Keyname? = nil) -> Key? {
        var iden: Key?
        if let name {
            iden = keyMapTable[name]
            if let key { iden? &= key.service }
        }
        if iden == nil, let key {
            iden = keyCache.first { $0 == key }
        }
        return iden
    }
    
    // !!!: Item
    
    public mutating func disk(cache item: CombineItem, for name: Keyname? = nil) {
        disk(cache: item.key, for: name)
        itemCache.setValue(item, forKey: item.key)
    }
    
    public func diskItem(for key: Key? = nil, keyName name: Keyname? = nil) -> CombineItem? {
        var item: CombineItem? = nil
//        let iden = diskKey(for: key, keyName: name)
//        if let iden {
//            item = itemCache.value(forKey: iden)
//            item?.key &= iden.service
//        }
//        if item == nil, let key {
//            item = itemCache.value(forKey: key)
//            item?.key &= key.service
//        }
        return item
    }
}

public extension Cache {
    static var appGroup: String = ""
    static var fileURL: URL {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)!
    }
    
//    static lazy let db: Database = {
//        let db = Database(withPath: fileURL.appendingPathComponent("schedule_WCDB").path)
//        return db
//    }()
}
