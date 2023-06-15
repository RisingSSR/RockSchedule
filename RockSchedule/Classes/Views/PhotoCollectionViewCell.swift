//
//  PhotoCollectionViewCell.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/14.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    public enum ReuseIdentifier {
        case adding
        case pointer
        case placehoder
        
        public var rawValue: String {
            switch self {
            case .adding: return "RockSchedule.PhotoCollectionViewCell.adding"
            case .pointer: return "RockSchedule.PhotoCollectionViewCell.pointer"
            case .placehoder: return "RockSchedule.PhotoCollectionViewCell.placehoder"
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
    
    open func placehoder(is404: Bool) {
        let width = contentView.frame.width - 40
        imgView.frame.size = CGSize(width: width, height: width * 0.65)
        imgView.center = CGPoint(x: contentView.frame.width / 2, y: contentView.frame.height / 2)
        let image = UIImage(resource: is404 ? R.image.scheduleEmptyError404 : R.image.scheduleEmptyNonclass)
        imgView.image = image
    }
    
    public private(set) var imgView: UIImageView = {
        UIImageView()
    }()
}
