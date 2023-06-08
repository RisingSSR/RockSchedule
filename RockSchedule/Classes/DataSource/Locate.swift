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

public class AnyLocatable: NSObject {
    private let box: NSObject
    
    public init<T: Locatable>(_ value: T) {
        box = AnyLocatableBoxImpl(value)
    }
    
    private func value<T: Locatable>() -> T? {
        (box as? AnyLocatableBoxImpl<T>)?.value
    }
    
    private class AnyLocatableBoxImpl<T: Locatable>: NSObject, Locatable {
        let value: T
        
        init(_ value: T) {
            self.value = value
        }
        
        override var hash: Int {
            value.section.hashValue ^ value.week.hashValue ^ value.location.hashValue
        }
        
        var section: Int { value.section }
        
        var week: Int { value.week }
        
        var location: Int { value.location }
    }
}

extension AnyLocatable: Locatable {
    
    public override var hash: Int {
        if let locate = (box as? (any Locatable)) {
            return locate.section.hashValue ^ locate.week.hashValue ^ locate.location.hashValue
        } else {
            fatalError("AnyLocatable does not contain a Locatable object")
        }
    }
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? AnyLocatable else { return false }
        return section == other.section && week == other.week && location == other.location
    }
    
    public var section: Int {
        if let locate = (box as? (any Locatable)) {
            return locate.section
        } else {
            fatalError("AnyLocatable does not contain a Locatable object")
        }
    }
    
    public var week: Int {
        if let locate = (box as? (any Locatable)) {
            return locate.week
        } else {
            fatalError("AnyLocatable does not contain a Locatable object")
        }
    }
    
    public var location: Int {
        if let locate = (box as? (any Locatable)) {
            return locate.location
            
        } else {
            fatalError("AnyLocatable does not contain a Locatable object")
        }
    }
    
    public override var description: String {
        "\(section)-\(week)-\(location)"
    }
}

public extension AnyLocatable {
    private struct Point: Locatable {
        let section: Int
        let week: Int
        let location: Int
    }
    
    convenience init(section s: Int, week w: Int, location l: Int) {
        self.init(Point(section: s, week: w, location: l))
    }
}
