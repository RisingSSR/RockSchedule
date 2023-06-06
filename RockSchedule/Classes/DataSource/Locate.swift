//
//  Locate.swift
//  RockSchedule
//
//  Created by SSR on 2023/5/23.
//

import Foundation

public protocol Locatable: Hashable {
    var section: Int { get }
    var week: Int { get }
    var location: Int { get }
}

@objc public protocol AnyLocatableBox {
    func hashx() -> Int
}

public class AnyLocatable: NSObject {
    private let box: AnyLocatableBox
    
    public init<T: Locatable>(_ value: T) {
        box = AnyLocatableBoxImpl(value)
    }
    
    private class AnyLocatableBoxImpl<T: Locatable>: NSObject, AnyLocatableBox {
        let value: T
        
        init(_ value: T) {
            self.value = value
        }
        
        func hashx() -> Int {
            return value.section.hashValue ^ value.week.hashValue ^ value.location.hashValue
        }
    }
    
    public override var hash: Int {
        return box.hashx()
        let a = IndexSet()
    }
    
    public static func == (lhs: AnyLocatable, rhs: AnyLocatable) -> Bool {
        return lhs.box.hashx() == rhs.box.hashx()
    }
}

extension AnyLocatable: Locatable {
    public var section: Int {
        if let locatable = box as? (any Locatable) {
            return locatable.section
        } else {
            fatalError("AnyLocatable does not contain a Locatable object")
        }
    }
    
    public var week: Int {
        if let locatable = box as? (any Locatable) {
            return locatable.week
        } else {
            fatalError("AnyLocatable does not contain a Locatable object")
        }
    }
    
    public var location: Int {
        if let locatable = box as? (any Locatable) {
            return locatable.location
        } else {
            fatalError("AnyLocatable does not contain a Locatable object")
        }
    }
}
