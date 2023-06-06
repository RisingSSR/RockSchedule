//
//  DoubleMap.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/2.
//

import UIKit

open class DoubleMap: Map {
    public private(set) var keys: [Cache.Keyname: CombineItem]
    public private(set) var finalAry: [[Map.Node]]
    
    public override init() {
        keys = [:]
        finalAry = []
        super.init()
    }
    
    public func insert(item: CombineItem, for keyName: Cache.Keyname) {
        for value in item.values {
            insert(course: value, with: item.key)
        }
    }
    
    open override func finish() {
        super.finish()
        for final in finalMap {
            if finalAry.count <= final.key {
                for _ in finalAry.count...final.key {
                    finalAry.append([])
                }
            }
            
//            for node in final.value {
//                for rangeView in node.locate.rangeView {
//                    var node = node
//                    node.locate = IndexSet(rangeView)
//                    finalAry[final.key].append(node)
//                }
//            }
        }
    }
}
