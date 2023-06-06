//
//  Service.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/2.
//

import UIKit
 
open class Service: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, CollectionViewLayoutDataSource {
    
    public private(set) var map = DoubleMap()
    private var _scrollViewStartPosPoint: CGPoint = .zero
    private var _scrollDirection: Int = 0
    
    open func seting(collectionView view: inout UICollectionView!, withPrepareWidth width:CGFloat) {
        let layout = CollectionViewLayout()
        layout.widthForLeadingSupplementaryView = 30
        layout.lineSpacing = 2
        layout.columnSpacing = 2
        layout.ratio = 50.0 / 46.0
        layout.heightForHeaderSupplementaryView = ((width - layout.widthForLeadingSupplementaryView) / 7 - layout.columnSpacing) * layout.ratio
        layout.dataSource = self
        
        view = UICollectionView(frame: CGRect(x: 0, y: 0, width: width, height: 0), collectionViewLayout: layout)
        view.register(ContentCollectionViewCell.self, forCellWithReuseIdentifier: ContentCollectionViewCell.reuseIdentifier)
    }
    
    // MARK: UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        max(map.finalAry.count, 24)
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section < 0 || section >= map.finalAry[section].count { return 0 }
        return map.finalAry[section].count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCollectionViewCell.reuseIdentifier, for: indexPath) as! ContentCollectionViewCell
        
        
        
        return cell
    }
    
    // MARK: CollectionViewLayoutDataSource
    
    open func collectionView(_ collectionView: UICollectionView, persentFor indexPath: IndexPath) -> CGFloat {
        1
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CollectionViewLayout, locationForItemAt indexPath: IndexPath) -> AnyLocatable {
        map.pointMap.first!.key
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CollectionViewLayout, lenthLocate locate: AnyLocatable, at indexPath: IndexPath) -> Int {
        2
//        map.finalAry[indexPath.section][indexPath.item].locate.count
    }
}
