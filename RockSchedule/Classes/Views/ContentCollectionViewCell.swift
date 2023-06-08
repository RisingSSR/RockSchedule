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
    
    public var drawType: DrawType {
        willSet {
            switch newValue {
            case .morning:
                contentView.backgroundColor = R.color.backgroundAfternoon
                let a = 2
                titleLab.textColor = #colorLiteral(red: 1, green: 0.5019607843, blue: 0.08235294118, alpha: 1)
                contentLab.textColor = #colorLiteral(red: 1, green: 0.5019607843, blue: 0.08235294118, alpha: 1)
                multyView.backgroundColor = #colorLiteral(red: 1, green: 0.5019607843, blue: 0.08235294118, alpha: 1)
            case .afternoon:
                contentView.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.8901960784, blue: 0.8941176471, alpha: 1)
                titleLab.textColor = #colorLiteral(red: 1, green: 0.3843137255, blue: 0.3843137255, alpha: 1)
                contentLab.textColor = #colorLiteral(red: 1, green: 0.3843137255, blue: 0.3843137255, alpha: 1)
                multyView.backgroundColor = #colorLiteral(red: 1, green: 0.3843137255, blue: 0.3843137255, alpha: 1)
            case .night:
                contentView.backgroundColor = #colorLiteral(red: 0.8666666667, green: 0.8901960784, blue: 0.9725490196, alpha: 1)
                titleLab.textColor = #colorLiteral(red: 0.2509803922, green: 0.4, blue: 0.9176470588, alpha: 1)
                contentLab.textColor = #colorLiteral(red: 0.2509803922, green: 0.4, blue: 0.9176470588, alpha: 1)
                multyView.backgroundColor = #colorLiteral(red: 0.2509803922, green: 0.4, blue: 0.9176470588, alpha: 1)
            case .others:
                contentView.backgroundColor = #colorLiteral(red: 0.8745098039, green: 0.9529411765, blue: 0.9882352941, alpha: 1)
                titleLab.textColor = #colorLiteral(red: 0.02352941176, green: 0.6392156863, blue: 0.9882352941, alpha: 1)
                contentLab.textColor = #colorLiteral(red: 0.02352941176, green: 0.6392156863, blue: 0.9882352941, alpha: 1)
                multyView.backgroundColor = #colorLiteral(red: 0.02352941176, green: 0.6392156863, blue: 0.9882352941, alpha: 1)
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
