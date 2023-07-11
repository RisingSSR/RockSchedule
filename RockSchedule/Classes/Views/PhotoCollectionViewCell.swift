//
//  PhotoCollectionViewCell.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/14.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    public enum ReuseIdentifier: CaseIterable {
        
        public enum Placehoder: CaseIterable {
            case requesting
            case error404
            case noclass
        }
        
        case adding
        case pointer
        case placehoder(Placehoder)
        
        public static var allCases: [PhotoCollectionViewCell.ReuseIdentifier] {
            [.adding, .pointer, .placehoder(.requesting)]
        }
        
        public var identifier: String {
            switch self {
            case .adding: return "RockSchedule.PhotoCollectionViewCell.ReuseIdentifier.adding"
            case .pointer: return "RockSchedule.PhotoCollectionViewCell.ReuseIdentifier.pointer"
            case .placehoder(_): return "RockSchedule.PhotoCollectionViewCell.ReuseIdentifier.placehoder"
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imgView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func placehoder(in type: ReuseIdentifier.Placehoder = .noclass) {
        let width = contentView.frame.width - 40
        imgView.frame.size = CGSize(width: width, height: width * 0.65)
        imgView.center = CGPoint(x: contentView.frame.width / 2, y: contentView.frame.height / 2)
        var image: UIImage!
        switch type {
        case .noclass: image = UIImage(resource: R.image.scheduleEmptyNonclass)
        case .error404: image = UIImage(resource: R.image.scheduleEmptyError404)
        case .requesting: image = UIImage(resource: R.image.scheduleEmptyNonclass)
        }
        imgView.image = image
    }
    
    public private(set) var imgView: UIImageView = {
        UIImageView()
    }()
    
    public private(set) var descripLab: UILabel = {
        let lab = UILabel()
        lab.font = UIFont.fontName(FontName.PingFangSC.regular, size: 12)
        lab.textColor = UIColor(resource: R.color.scheduleSupplyContentUnselect)
        return lab
    }()
}
