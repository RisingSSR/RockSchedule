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
    
    open func createCollectionView(prepareWidth width: CGFloat) -> UICollectionView {
        let layout = CollectionViewLayout()
        layout.widthForLeadingSupplementaryView = 30
        layout.lineSpacing = 2
        layout.columnSpacing = 2
        layout.ratio = 50.0 / 46.0
        layout.heightForHeaderSupplementaryView = ((width - layout.widthForLeadingSupplementaryView) / 7 - layout.columnSpacing) * layout.ratio
        layout.dataSource = self
        
        let view = UICollectionView(frame: CGRect(x: 0, y: 0, width: width, height: 0), collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.register(ContentCollectionViewCell.self, forCellWithReuseIdentifier: ContentCollectionViewCell.reuseIdentifier)
        
        return view
    }
    
    // MARK: UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("numberOfSections\(map.final.count)")
        return max(map.final.count, 24)
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section >= map.final.count { return 0 }
        return map.final[section]?.count ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCollectionViewCell.reuseIdentifier, for: indexPath) as! ContentCollectionViewCell
        
        cell.contentView.backgroundColor = .green
        
        return cell
    }
    
    // MARK: CollectionViewLayoutDataSource
    
    open func collectionView(_ collectionView: UICollectionView, persentFor indexPath: IndexPath) -> CGFloat {
        1
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CollectionViewLayout, locationForItemAt indexPath: IndexPath) -> AnyLocatable {
        let rangeElem = map.final[indexPath.section]![indexPath.item].locates
        return AnyLocatable(section: indexPath.section, week: indexPath.item, location: rangeElem.lowerBound)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CollectionViewLayout, lenthLocate locate: AnyLocatable, at indexPath: IndexPath) -> Int {
        map.pointMap[locate]?.count ?? 0
    }
}
