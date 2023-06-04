//
//  Map.swift
//  RockSchedule
//
//  Created by SSR on 2023/5/22.
//

import Foundation

// MARK: Map

open class Map {
    
    public enum Kind: Int, Codable {
        case system = 0
        case custom = 1
        case others = 2
    }
    
    public struct Node {
        public let key: Key             // 个人信息
        public let value: Course        // 课程信息
        public let kind: Kind           // 所属类型
    }
    
    public struct Origin {
        public var locate: AnyLocatable
        public let node: Node
    }
    
    public var sno: String?
    
    public private(set) var pointMap: [AnyLocatable: LinkedList<Node>] = [:]
    public private(set) var finalSet: [Int: Set<Origin>] = [:]
    
    public init() {
    }
    
    open func map(course: Course, with key: Key) {
        let kind = self.kind(of: course, with: key)
        let node = Node(key: key, value: course, kind: kind)
        for locate in course.locates {
            insert(node: node, in: locate)
        }
    }
    
    public func insert(node newValue: Node, in locate: AnyLocatable) {
        let origin = Origin(locate: locate, node: newValue)
        if var list = pointMap[locate] {
            let oldOrigin = Origin(locate: locate, node: list.head!)
            finalSet[locate.section]?.remove(oldOrigin)
            finalSet[locate.section]?.insert(origin)
            
            let index = list.firstIndex { oldValue in
                if newValue.kind < oldValue.kind { return true }
                if newValue.kind == oldValue.kind {
                    if newValue.value.inPeriods.count >= oldValue.value.inPeriods.count {
                        return true
                    }
                }
                return false
            } ?? list.endIndex
            list.insert(newValue, at: index)
            pointMap[locate] = list
        } else {
            pointMap[locate] = LinkedList(arrayLiteral: newValue)
        }
        
        if var set = finalSet[locate.section] {
            if let oldValue = set.remove(origin) {
                if origin.locate.location <= oldValue.locate.location {
                    finalSet[locate.section]?.update(with: origin)
                }
            } else {
                finalSet[locate.section]?.insert(origin)
            }
        } else {
            finalSet[locate.section] = Set(arrayLiteral: origin)
        }
    }
    
    open func kind(of course: Course, with key: Key) -> Kind {
        guard let sno else { return .system }
        if sno == key.sno {
            if key.type != .custom {
                return .system
            } else {
                return .custom
            }
        } else {
            return .others
        }
    }
}

// MARK: ex Map.Kind: Comparable

extension Map.Kind: Comparable {
    public static func == (lhs: Map.Kind, rhs: Map.Kind) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
    public static func < (lhs: Map.Kind, rhs: Map.Kind) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: ex Map.Node: Hashable
extension Map.Node: Hashable {
    public static func == (lhs: Map.Node, rhs: Map.Node) -> Bool {
        lhs.key == rhs.key
        && lhs.kind == rhs.kind
        && lhs.value == rhs.value
    }

    public var hashValue: Int {
        key.hashValue << 1
        + kind.rawValue
        + value.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        key.hash(into: &hasher)
        value.hash(into: &hasher)
    }
}

// MARK: ex Map.Origin: Hashable
extension Map.Origin: Hashable {
    public static func == (lhs: Map.Origin, rhs: Map.Origin) -> Bool {
        lhs.node == rhs.node
    }

    public var hashValue: Int {
        node.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        node.hash(into: &hasher)
    }
}

// MARK: ex Map.Node: CustomDebugStringConvertible
extension Map.Node: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(kind.rawValue)-\(key.sno)-\(value.course)"
    }
}

// MARK: ex Course
extension Course {
    
    private struct Point: Locatable {
        let section: Int
        let week: Int
        let location: Int
    }
    
    public var locates: [AnyLocatable] {
        var locate = [AnyLocatable]()
        for period in inPeriods {
            for section in inSections {
                locate.append(AnyLocatable(Point(section: section, week: inDay, location: period)))
            }
            locate.append(AnyLocatable(Point(section: 0, week: inDay, location: period)))
        }
        return locate
    }
}
