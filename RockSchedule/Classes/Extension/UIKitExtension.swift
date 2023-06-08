//
//  UIKitExtension.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/4.
//

import UIKit

public typealias FontName = String

public extension FontName {
    struct PingFangSC {
        static let regular = "PingFangHK-Regular"
        static let ultralight = "PingFangSC-Ultralight"
        static let thin = "PingFangSC-Thin"
        static let light = "PingFangSC-Light"
        static let medium = "PingFangSC-Medium"
        static let semibold = "PingFangSC-Semibold"
    }
}

public extension UIFont {
    class func fontName(_ fontName: FontName, size fontSize: CGFloat) -> UIFont {
        return UIFont(name: fontName, size: fontSize)!
    }
}
