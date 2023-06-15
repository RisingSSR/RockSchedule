//
//  InteractiveService.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/9.
//

import UIKit

open class InteractiveService: DataSourceService, UIGestureRecognizerDelegate {
    
    public private(set) var collectionView: UICollectionView!
    public var layout: CollectionViewLayout {
        if let layout = collectionView.collectionViewLayout as? CollectionViewLayout {
            return layout
        } else {
            fatalError("layout is not a kind of 'CollectionViewLayout'")
        }
    }
    
    open func scroll(to section: Int, animated: Bool = true) {
        var section = max(section, 0)
        section = min(section, map.sections)
        let contentOffsetY = collectionView.contentOffset.y
        let x = CGFloat(section) * (collectionView.frame.width / CGFloat(layout.numberOfPages))
        collectionView.setContentOffset(CGPoint(x: x, y: contentOffsetY), animated: animated)
    }
    
    // MARK: override
    
    open override func createCollectionView(prepareWidth width: CGFloat) -> UICollectionView {
        collectionView = super.createCollectionView(prepareWidth: width)
        collectionView.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(InteractiveService.empty(tap:)))
        tap.delegate = self
        collectionView.addGestureRecognizer(tap)
        return collectionView
    }
    
    // MARK: Private
    @objc
    private func empty(tap: UITapGestureRecognizer) {
        
    }
}
