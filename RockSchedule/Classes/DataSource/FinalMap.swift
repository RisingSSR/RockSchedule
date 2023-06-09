//
//  DoubleMap.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/2.
//

import UIKit

open class FinalMap: Map {
    
    public enum KeyFetal {
        case double
        case group
    }
    
    public private(set) var keys: [AnyHashable: CombineItem]
    public private(set) var sections: Int
    
    public private(set) var startDate: Date?
    
    public var useImmediate: Bool = false
    private var finalRange: [[(model: Map.Node, locates: IndexSet.RangeView.Element)]]
    
    public let keyFetal: KeyFetal
    
    public var final: [[(model: Map.Node, locates: IndexSet.RangeView.Element)]]{
        if useImmediate { return finalRange }
        useImmediate = true
        finalRange.removeAll(keepingCapacity: true)
        
        for nodeEntry in nodeMap {
            while finalRange.count <= nodeEntry.value.count { finalRange.append([]) }
            for index in 0..<nodeEntry.value.count {
                var final = finalRange[index]
                for rangeView in nodeEntry.value[index].rangeView {
                    final.append((nodeEntry.key, rangeView))
                }
                finalRange[index] = final
            }
        }
        return finalRange
    }
    
    // MARK: M
    
    public init(keyFetal: KeyFetal) {
        self.keyFetal = keyFetal
        switch keyFetal {
        case .double: keys = [Cache.Keyname: CombineItem]()
        case .group: keys = [Key: CombineItem]()
        }
        finalRange = [[]]
        sections = 0
        super.init()
    }
    
    open func insert(item: CombineItem) {
        switch keyFetal {
        case .double:
            let kind = kind(with: item.key)
            keys[kind] = item
        case .group:
            let key = item.key
            keys[key] = item
        }
        
        if item.key.type != .custom { startDate = item.key.start }
        for value in item.values {
            insert(course: value, with: item.key)
            sections = max(sections, value.inSections.last ?? sections)
        }
    }
    
    open override func insert(node newValue: Map.Node, in locate: AnyLocatable) {
        useImmediate = false
        super.insert(node: newValue, in: locate)
    }
}
