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
    
    public struct SectionModel {
        public struct ItemModel {
            public let model: Map.Node
            public let locates: IndexSet.RangeView.Element
        }
        public var startDate: Date?
        public var specialTime: Set<Course.SpecialTime> = []
        public var values: [ItemModel] = []
    }
    
    public private(set) var keys: [AnyHashable: CombineItem]
    public private(set) var sections: Int
    public private(set) var nowWeek: Int
    public private(set) var startDate: Date?
    public var showWeek: Int { nowWeek < 0 ? 0 : min(nowWeek, sections) }
    
    public var useImmediate: Bool = false
    private var finalRange: [SectionModel]
    
    public let keyFetal: KeyFetal
    
    public var final: [SectionModel]{
        if useImmediate { return finalRange }
        useImmediate = true
        sections = 0
        finalRange.removeAll(keepingCapacity: true)
        
        for nodeEntry in nodeMap {
            sections = max(sections, nodeEntry.value.count)
            while finalRange.count <= sections { finalRange.append(SectionModel()) }
            for index in 0..<nodeEntry.value.count {
                var final = finalRange[index]
                for rangeView in nodeEntry.value[index].rangeView {
                    let itemModel = SectionModel.ItemModel(model: nodeEntry.key, locates: rangeView)
                    final.values.append(itemModel)
                }
                finalRange[index] = final
            }
        }
        if sections >= 1 {
            for i in 1...sections {
                finalRange[i].startDate = startDate?.add(.weekOfYear, value: i - 1)
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
        finalRange = [SectionModel()] // for section 0
        sections = 0
        nowWeek = 0
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
        
        for value in item.values {
            insert(course: value, with: item.key)
        }
        if item.key.type != .custom {
            startDate = item.key.start
            nowWeek = (Calendar(identifier: .gregorian).dateComponents([.weekOfYear], from: startDate ?? Date(), to: Date()).weekOfYear ?? -1) + 1
        }
    }
    
    open override func insert(node newValue: Map.Node, in locate: AnyLocatable) {
        useImmediate = false
        super.insert(node: newValue, in: locate)
    }
}
