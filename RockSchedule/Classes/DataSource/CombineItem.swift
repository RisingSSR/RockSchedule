//
//  CombineItem.swift
//  CyxbsMobileSwift
//
//  Created by SSR on 2023/5/12.
//

import Foundation

// MARK: class CombineItem

public class CombineItem {
    
    public var key: Key
    public private(set) var values: [Course]
    
    public init(key: Key, values: [Course] = []) {
        self.key = key
        self.values = values
    }
}

public extension CombineItem {
    
    convenience init(sno: String, kind: Key.Kind, values: [Course] = []) {
        let key = Key(sno: sno, type: kind)
        self.init(key: key, values: values)
    }
    
    func append(course: Course) {
        values.append(course)
    }
    
    func remove(at idx: Int) {
        values.remove(at: idx)
    }
}

extension CombineItem: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(key.debugDescription) - \(values.count)"
    }
}
