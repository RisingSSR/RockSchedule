//
//  Service.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/2.
//

import UIKit
 
open class Service: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, CollectionViewLayoutDataSource {
    
    public private(set) var map = Map()
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
        /*
         [*view registerClass:ScheduleCollectionViewCell.class forCellWithReuseIdentifier:ScheduleCollectionViewCellReuseIdentifier]; // cell
         [*view registerClass:ScheduleSupplementaryCollectionViewCell.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:ScheduleSupplementaryCollectionViewCellReuseIdentifier]; // section header
         [*view registerClass:ScheduleSupplementaryCollectionViewCell.class forSupplementaryViewOfKind:UICollectionElementKindSectionLeading withReuseIdentifier:ScheduleSupplementaryCollectionViewCellReuseIdentifier]; // section leading
         [*view registerClass:SchedulePlaceholderCollectionViewCell.class forSupplementaryViewOfKind:UICollectionElementKindSectionPlaceholder withReuseIdentifier:SchedulePlaceholderCollectionViewCellReuseIdentifier]; // section placeholder
         [*view registerClass:ScheduleLeadingHolderCollectionViewCell.class forSupplementaryViewOfKind:UICollectionElementKindSectionHolder withReuseIdentifier:ScheduleLeadingHolderCollectionViewCellReuseIdentifier]; // section holder
         
         (*view).dataSource = self;
         (*view).delegate = self;
         */
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        max(map.finalSet.count, 24)
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        map.finalSet[section]?.count ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        UICollectionViewCell()
    }
    
    open func collectionView(_ collectionView: UICollectionView, persentFor indexPath: IndexPath) -> CGFloat {
        3.0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CollectionViewLayout, locationForItemAt indexPath: IndexPath) -> AnyLocatable {
        
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CollectionViewLayout, lenthAtLocale locate: AnyLocatable) -> Int {
        
    }
    
}
