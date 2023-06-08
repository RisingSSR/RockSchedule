//
//  DoubleMap.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/2.
//

import UIKit

open class DoubleMap: Map {
    public private(set) var keys: [Cache.Keyname: CombineItem]
    public private(set) var sections: Int
    
    public var useImmediate: Bool = false
    private var finalRange: [[(model: Map.Node, locates: IndexSet.RangeView.Element)]]
    
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
    
    public override init() {
        keys = [:]
        finalRange = []
        sections = 0
        super.init()
    }
    
    open func insert(item: CombineItem) {
        let kind = kind(with: item.key)
        keys[kind] = item
        
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
