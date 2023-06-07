//
//  Course.swift
//  Pods-RockSchedule_Example
//
//  Created by SSR on 2023/5/22.
//

import Foundation
import WCDBSwift
import SwiftyJSON

// MARK: struct Course

public struct Course: Codable {
    
    static let normalTime = 1...12
    
    /// 特殊时间
    public enum SpecialTime: Int, Codable, CaseIterable {
        
        case noon   /// 中午
        
        case night  /// 晚上
        
        public var rawValue: Int {
            switch self {
            case .noon: return 1 << 4
            case .night: return 1 << 5
            }
        }
        
        public var trueValue: CGFloat {
            switch self {
            case .noon: return 4.5
            case .night: return 8.5
            }
        }
        
        public var description: String {
            switch self {
            case .noon: return "中午"
            case .night: return "晚上"
            }
        }
    }
    
    /// [1...7] 对应周一到周日
    public var inDay: Int
    /// [1..] 对应1到n周，若需要整学期，请自行判断
    public var inSections: IndexSet
    /// [1...12], [1 << 5], [1 << 6 ]  对应1到12节，中午，晚上
    public var inPeriods: IndexSet

    /// 标题（什么课）
    public var course: String
    /// 内容（在哪儿上）
    public var classRoom: String
    
    /// 选修类型 [必修, 选修, 重修, 先修, 事务]
    public var type: String
    /// 课程唯一编号（事务可以没有）
    public var courseID: String?
    /// 老师 [xxx, 自定义]
    public var teacher: String
    
    /// 循环周期（事务需要根据`inSections`自行计算赋值）\e.g. "3-19周单周"
    public var rawWeek: String?
    /// 哪几节（事务需要根据`period`自行计算）\e.g. "三四节"
    public var lesson: String?
    /// “星期x”
    public var day: String? {
        if inDay < 1 || inDay > 7 { return nil }
        let weekDayV = inDay < 7 ? inDay + 1 : 1
        guard let date = Date().reset(.weekday, value: weekDayV) else { return nil }
        return date.string(withFormat: "EEEE", timeZone: .CQ)
    }
    
    /// 通用的创建方法
    public init(inDay: Int, inSections: IndexSet, inPeriods: IndexSet,
                course: String, classRoom: String,
                type: String = "事务", courseID: String? = nil, teacher: String = "自定义",
                rawWeek: String? = nil, lesson: String? = nil) {
        self.inDay = inDay
        self.inSections = inSections
        self.inPeriods = inPeriods
        
        self.course = course
        self.classRoom = classRoom
        self.type = type
        self.courseID = courseID
        self.teacher = teacher
        
        self.rawWeek = rawWeek
        self.lesson = lesson
    }
}

// MARK: ex Init

public extension Course {
    
    init(fromJSON json: JSON) {
        let inDay = json["hash_day"].intValue + 1
        let inSections = IndexSet(json["week"].arrayObject as! [Int])
        let location = json["begin_lesson"].intValue
        let lenth = json["period"].intValue
        let inPeriods = IndexSet(location..<location + lenth)
        
        let course = json["course"].stringValue
        let classRoom = json["classroom"].stringValue
        let type = json["type"].stringValue
        let courseID = json["course_num"].string
        let teacher = json["teacher"].stringValue
        
        let rawWeek = json["rawWeek"].string
        let lesson = json["lesson"].string
        self.init(inDay: inDay, inSections: inSections, inPeriods: inPeriods,
                  course: course, classRoom: classRoom, type: type, courseID: courseID,
                  teacher: teacher, rawWeek: rawWeek, lesson: lesson)
    }
    
    static func json(from json: JSON) -> Self {
        return Course(fromJSON: json)
    }
    
    static func custom(inDay: Int, inSections: IndexSet, inPeriods: IndexSet,
                       course: String, classRoom: String) -> Course {
        let courseID = "custom\(Date().timeIntervalSince1970)"
        let rawWeek = inSections.rangeView.map { range in
            range.count == 1 ? "\(range.lowerBound)" : "\(range.lowerBound)-\(range.upperBound - 1)"
        }.joined(separator: ", ") + "周"
        
        let lesson = inPeriods.rangeView.compactMap { range in
            if range.lowerBound >= normalTime.lowerBound && range.upperBound <= normalTime.upperBound + 1 {
                return "\(range.lowerBound)-\(range.upperBound - 1)节"
            }
            return SpecialTime(rawValue: range.lowerBound)?.description
        }.joined(separator: ", ")
        
        return Course(inDay: inDay, inSections: inSections, inPeriods: inPeriods,
                      course: course, classRoom: classRoom,
                      courseID: courseID, rawWeek: rawWeek, lesson: lesson)
    }
}

// MARK: ex Hashable

extension Course: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.inDay == rhs.inDay
        && lhs.courseID == rhs.courseID
        && lhs.course == rhs.course
        && lhs.classRoom == rhs.classRoom
    }
    
    public var hashValue: Int {
        (courseID?.hashValue ?? 0) << 2
        + inDay.hashValue ^ course.hashValue ^ classRoom.hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(inDay)
        hasher.combine(courseID)
        hasher.combine(course)
        hasher.combine(classRoom)
    }
}

extension Course: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(course)"
    }
}

// MARK: ex TableCodable

extension Course: TableCodable {
    
    public enum CodingKeys: String, CodingTableKey {
        public typealias Root = Course
        public static let objectRelationalMapping = TableBinding(CodingKeys.self)
        
        case inDay
        case inSections
        case inPeriods
        
        case course
        case classRoom
        
        case type
        case courseID
        case teacher
        case rawWeek
        case lesson
    }
}
