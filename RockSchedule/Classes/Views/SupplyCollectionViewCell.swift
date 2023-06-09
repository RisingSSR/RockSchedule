//
//  SupplyCollectionViewCell.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/8.
//

import UIKit

class SupplyCollectionViewCell: UICollectionViewCell {
    public static let reuseIdentifier = "RockSchedule.SupplyCollectionViewCell"
    
    public enum ContentType {
        case onlyTitle
        case content(String?)
    }
    
    // MARK: Make View
    
    open func title(_ title: String?, content: ContentType = .onlyTitle) {
        titleLab.text = title
        self.content = content
        switch content {
        case .onlyTitle:
            titleLab.center.y = contentView.frame.size.height / 2
            contentLab.isHidden = true
        case .content(let str):
            titleLab.frame.origin.y = 6
            contentLab.text = str
            contentLab.sizeToFit()
            contentLab.frame.origin.y = contentView.frame.size.height - contentLab.frame.height - 3
            contentLab.isHidden = false
        }
    }
    
    public var title: String? { titleLab.text }
    
    public private(set) var content: ContentType?
    
    public var isCurrent: Bool {
        willSet {
            if newValue {
                contentView.backgroundColor = UIColor(resource: R.color.scheduleSupplyBackground)
                titleLab.textColor = UIColor(resource: R.color.scheduleSupplyTitleSelect)
                contentLab.textColor = UIColor(resource: R.color.scheduleSupplyContentSelect)
            } else {
                contentView.backgroundColor = .clear
                titleLab.textColor = UIColor(resource: R.color.scheduleSupplyTitleUnselect)
                contentLab.textColor = UIColor(resource: R.color.scheduleSupplyContentUnselect)
            }
        }
    }
    
    // MARK: init
    
    override init(frame: CGRect) {
        isCurrent = false
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        contentView.addSubview(titleLab)
        contentView.addSubview(contentLab)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        titleLab.frame.size.width = layoutAttributes.size.width
        contentLab.frame.size.width = layoutAttributes.size.width
    }
    
    // MARK: Lazy
    
    public private(set) var titleLab: UILabel = {
        let lab = UILabel(frame: CGRect(x: .zero, y: 6, width: .zero, height: 20))
        lab.backgroundColor = .clear
        lab.textAlignment = .center
        lab.numberOfLines = 2
        lab.font = UIFont.fontName(.PingFangSC.regular, size: 12)
        return lab
    }()
    
    public private(set) var contentLab: UILabel = {
        let lab = UILabel()
        lab.frame.size.height = 20
        lab.backgroundColor = .clear
        lab.textAlignment = .center
        lab.font = UIFont.fontName(.PingFangSC.regular, size: 11)
        return lab
    }()
}
