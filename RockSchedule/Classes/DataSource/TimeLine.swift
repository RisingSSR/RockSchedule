//
//  TimeLine.swift
//  RockSchedule
//
//  Created by SSR on 2023/5/22.
//

import Foundation

// MARK: TimeLine

public struct TimeLine: Codable {
    
    public enum Layout: Codable {
        
        case normal(Int) // 1...14
        
        case special(Course.SpecialTime) // 中午/晚上
        
        public var description: String {
            switch self {
            case .normal(let num):
                return "\(num)"
            case .special(let special):
                return special.description
            }
        }
    }
    
    // MARK: struct Part
    
    public struct Part: Codable {
        
        public let layout: Layout
        public let from: DateComponents
        public let to: DateComponents
        
        public init(layout: Layout, from: [Calendar.Component: Int], to: [Calendar.Component: Int]) {
            self.layout = layout
            var f = DateComponents(), t = DateComponents()
            from.forEach { per in
                f.setValue(per.value, for: per.key)
            }
            to.forEach { per in
                t.setValue(per.value, for: per.key)
            }
            self.from = f
            self.to = t
        }
        
        public var fromDescription: String {
            String(format: "%02d-%02d", from.hour ?? 0, from.minute ?? 0)
        }
        public var toDescription: String {
            String(format: "%02d-%02d", to.hour ?? 0, to.minute ?? 0)
        }
    }
    
    public var special: Set<Course.SpecialTime>
    
    public var count: Int {
        return 12 + special.count
    }
    
    public init(special: Set<Course.SpecialTime> = []) {
        self.special = special
    }
    
    public static subscript(layout: Layout) -> Part {
        switch layout {
        case .normal(let idx):
            if Course.normalTime.contains(idx) {
                return partAry[idx - 1]
            }
            fatalError("the idex \(idx) must in \(Course.normalTime)")
        case .special(let special):
            switch special {
            case .noon: return partAry[12]
            case .night: return partAry[13]
            }
        }
    }
    
    // 用于Map的时候，直接布局
    private static let partAry: [Part] = {
        [
            Part(layout: .normal( 1), from: [.hour:  8, .minute:  0], to: [.hour:  8, .minute: 45]),    // 0
            Part(layout: .normal( 2), from: [.hour:  8, .minute: 55], to: [.hour:  9, .minute: 40]),
            Part(layout: .normal( 3), from: [.hour: 10, .minute: 15], to: [.hour: 11, .minute:  0]),
            Part(layout: .normal( 4), from: [.hour: 11, .minute: 10], to: [.hour: 11, .minute: 55]),
            
            Part(layout: .normal( 5), from: [.hour: 14, .minute:  0], to: [.hour: 14, .minute: 45]),    // 4
            Part(layout: .normal( 6), from: [.hour: 14, .minute: 55], to: [.hour: 15, .minute: 40]),
            Part(layout: .normal( 7), from: [.hour: 16, .minute: 15], to: [.hour: 17, .minute:  0]),
            Part(layout: .normal( 8), from: [.hour: 17, .minute: 10], to: [.hour: 17, .minute: 55]),
            
            Part(layout: .normal( 9), from: [.hour: 19, .minute:  0], to: [.hour: 19, .minute: 45]),    // 8
            Part(layout: .normal(10), from: [.hour: 19, .minute: 55], to: [.hour: 20, .minute: 40]),
            Part(layout: .normal(11), from: [.hour: 20, .minute: 50], to: [.hour: 21, .minute: 35]),
            Part(layout: .normal(12), from: [.hour: 21, .minute: 45], to: [.hour: 22, .minute: 30]),
                        
            Part(layout: .special(.noon), from: [.hour: 12, .minute: 10], to: [.hour: 13, .minute: 45]),  // 12
            Part(layout: .special(.night), from: [.hour: 18, .minute: 10], to: [.hour: 18, .minute: 45])  // 13
        ]
    }()
}

// MARK: ex TimeLine.Layout: Comparable

extension TimeLine.Layout: Comparable {
    public static func < (lhs: TimeLine.Layout, rhs: TimeLine.Layout) -> Bool {
        switch lhs {
        case .normal(let lint):
            switch rhs {
            case .normal(let rint):
                return lint < rint
            case .special(let rspecialTime):
                return CGFloat(lint) < rspecialTime.trueValue
            }
        case .special(let lspecialTime):
            switch rhs {
            case .normal(let rint):
                return lspecialTime.trueValue < CGFloat(rint)
            case .special(let rspecialTime):
                return lspecialTime.trueValue <  rspecialTime.trueValue
            }
        } 
    }
}

// MARK: ex Course

public extension Course {
    
    /// 转为时间线
    var layout: [TimeLine.Layout] {
        var layout = [TimeLine.Layout]()
        for idx in inPeriods {
            if Course.normalTime.contains(idx) {
                layout.append(.normal(idx))
            } else if let special = SpecialTime(rawValue: idx) {
                layout.append(.special(special))
            }
        }
        return layout.sorted(by: <)
    }
    
    /// 时间 \e.g. "14:00 - 17:55"
    var timeStr: String {
        let layout = layout
        guard let fist = layout.first, let last = layout.last else { return "" }
        return "\(TimeLine[fist].fromDescription) - \(TimeLine[last].toDescription)"
    }
}
