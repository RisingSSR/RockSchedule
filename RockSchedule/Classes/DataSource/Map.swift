//
//  Map.swift
//  RockSchedule
//
//  Created by SSR on 2023/5/22.
//

import Foundation

// MARK: Map

open class Map {
    
    public struct Node: Codable {
        public let key: Key             // 个人信息
        public let value: Course        // 课程信息
        public let kind: Cache.Keyname           // 所属类型
    }
    
    public var sno: String?
    
    public private(set) var pointMap: [AnyLocatable: LinkedList<Node>] = [:]
    public private(set) var nodeMap: [Node: [IndexSet]] = [:]
    
    public init() { }
    
    open func insert(course: Course, with key: Key) {
        let kind = self.kind(of: course, with: key)
        let node = Node(key: key, value: course, kind: kind)
        for locate in course.locates {
            insert(node: node, in: locate)
        }
    }
    
    open func insert(node newValue: Node, in locate: AnyLocatable) {
        if var list = pointMap[locate] {
            if let oldValue = list.head {
                nodeMap[oldValue]?[locate.section].remove(locate.location)
            }
            let index = list.firstIndex { oldValue in
                if newValue.kind < oldValue.kind { return true }
                if newValue.kind == oldValue.kind {
                    if newValue.value.periodCount >= oldValue.value.periodCount {
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
        
        if let node = pointMap[locate]?.first {
            var ordered = nodeMap[node] ?? []
            while ordered.count <= locate.section { ordered.append(.init()) }
            ordered[locate.section].insert(locate.location)
            nodeMap[node] = ordered
        }
    }
    
    open func kind(of course: Course? = nil, with key: Key) -> Cache.Keyname {
        guard let sno else { return .mine }
        if sno == key.sno {
            if key.type != .custom {
                return .mine
            } else {
                return .custom
            }
        } else {
            return .others
        }
    }
}

// MARK: ex Map.Node: Hashable
extension Map.Node: Hashable {
    public static func == (lhs: Map.Node, rhs: Map.Node) -> Bool {
        lhs.key == rhs.key
        && lhs.value == rhs.value
    }

    public var hashValue: Int {
        key.hashValue << 1
        + value.hashValue
    }

    public func hash(into hasher: inout Hasher) {
        key.hash(into: &hasher)
        value.hash(into: &hasher)
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
    
    public var locates: [AnyLocatable] {
        var locate = [AnyLocatable]()
        for var period in inPeriod {
            if period >= 9 { period += 1 }
            if period >= 5 { period += 1 }
            for section in inSections {
                locate.append(AnyLocatable(section: section, week: inDay, location: period))
            }
            locate.append(AnyLocatable(section: 0, week: inDay, location: period))
        }
        
        for special in inSpecial {
            for section in inSections {
                locate.append(AnyLocatable(section: section, week: inDay, location: special.rawValue))
            }
            locate.append(AnyLocatable(section: 0, week: inDay, location: special.rawValue))
        }
        return locate
    }
}
