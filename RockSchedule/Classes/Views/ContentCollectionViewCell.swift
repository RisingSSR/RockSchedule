//
//  ContentCollectionViewCell.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/4.
//

import UIKit
import RswiftResources

open class ContentCollectionViewCell: UICollectionViewCell {
    public static let reuseIdentifier = "RockSchedule.ContentCollectionViewCell"
    
    public enum DrawType: Int {
        case morning
        case afternoon
        case night
        case others
        case custom
    }
    
    // MARK: Make View
    
    public var drawType: DrawType {
        willSet {
            switch newValue {
            case .morning:
                contentView.backgroundColor = UIColor(resource: R.color.scheduleContentBackgroundAfternoon)
                titleLab.textColor = UIColor(resource: R.color.scheduleContentTextMorning)
                contentLab.textColor = UIColor(resource: R.color.scheduleContentTextMorning)
                multyView.backgroundColor = UIColor(resource: R.color.scheduleContentTextMorning)
            case .afternoon:
                contentView.backgroundColor = UIColor(resource: R.color.scheduleContentBackgroundAfternoon)
                titleLab.textColor = UIColor(resource: R.color.scheduleContentTextAfternoon)
                contentLab.textColor = UIColor(resource: R.color.scheduleContentTextAfternoon)
                multyView.backgroundColor = UIColor(resource: R.color.scheduleContentTextAfternoon)
            case .night:
                contentView.backgroundColor = UIColor(resource: R.color.scheduleContentBackgroundNight)
                titleLab.textColor = UIColor(resource: R.color.scheduleContentTextNight)
                contentLab.textColor = UIColor(resource: R.color.scheduleContentTextNight)
                multyView.backgroundColor = UIColor(resource: R.color.scheduleContentTextNight)
            case .others:
                contentView.backgroundColor = UIColor(resource: R.color.scheduleContentBackgroundOther)
                titleLab.textColor = UIColor(resource: R.color.scheduleContentTextOther)
                contentLab.textColor = UIColor(resource: R.color.scheduleContentTextOther)
                multyView.backgroundColor = UIColor(resource: R.color.scheduleContentTextOther)
            case .custom:
                break
            }
        }
    }
    
    public var title: String? {
        get { titleLab.text }
        set {
            titleLab.text = newValue
            titleLab.sizeToFit()
            titleLab.center.x = contentView.frame.width / 2
        }
    }
    
    public var content: String? {
        get { contentLab.text }
        set {
            contentLab.text = newValue
            contentLab.sizeToFit()
            contentLab.center.x = contentView.frame.width / 2
            contentLab.frame.origin.y = frame.height - contentLab.frame.height - 8
        }
    }
    
    public var isMulty: Bool {
        set { multyView.isHidden = !newValue }
        get { !multyView.isHidden}
    }
    
    public var oneLenth: Bool {
        set { contentLab.isHidden = newValue }
        get { contentLab.isHidden }
    }
    
    // MARK: init
    
    public override init(frame: CGRect) {
        drawType = .morning
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.addSubview(titleLab)
        contentView.addSubview(contentLab)
        contentView.addSubview(multyView)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        let frame = layoutAttributes.frame
        multyView.frame.origin.x = frame.width - multyView.frame.width - 5
        
        titleLab.frame.origin.y = 8
        titleLab.frame.size.width = contentView.frame.width - 2 * 8
        
        contentLab.frame.origin.y = frame.height - contentLab.frame.height - 8
        contentLab.frame.size.width = contentView.frame.width - 2 * 8
    }
    
    // MARK: lazy
    
    public private(set) lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = .clear
        lab.numberOfLines = 3
        lab.font = .fontName(.PingFangSC.regular, size: 10)
        lab.textAlignment = .center
        return lab
    }()
    
    public private(set) lazy var contentLab: UILabel = {
        let lab = UILabel()
        lab.backgroundColor = .clear
        lab.numberOfLines = 3
        lab.font = .fontName(.PingFangSC.regular, size: 10)
        lab.textAlignment = .center
        return lab
    }()
    
    public private(set) lazy var multyView: UIView = {
        let view = UIView(frame: CGRect(x: .zero, y: 4, width: 8, height: 2))
        view.layer.cornerRadius = view.frame.height / 2
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
}
