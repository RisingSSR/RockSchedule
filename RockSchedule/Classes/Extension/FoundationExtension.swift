//
//  FoundationExtension.swift
//  RockSchedule
//
//  Created by SSR on 2023/5/22.
//

import Foundation

public extension Locale {
    static var CQ: Self {
        Locale(identifier: "Asia/Chongqing")
    }
}

public extension TimeZone {
    static var CQ: Self {
        TimeZone(identifier: "Asia/Chongqing")!
    }
}

public extension DateComponents {
    var scheduleWeekday: Int? {
        guard let weekday else { return nil }
        return (weekday + 6) % 8 + (weekday + 6) / 8
    }
}

public extension Date {
    func reset(_ component: Calendar.Component, value: Int) -> Date? {
        Calendar(identifier: .republicOfChina).date(bySetting: component, value: value, of: self)
    }
    
    func string(withFormat format: String, locale: Locale? = nil, timeZone: TimeZone? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale ?? .current
        dateFormatter.timeZone = timeZone ?? .current
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}