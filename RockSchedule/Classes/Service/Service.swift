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
        return max(map.final.count, 24)
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section >= map.final.count { return 0 }
        return map.final[section].count ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let value = map.final[indexPath.section][indexPath.item]
        let model = value.model
        let locate = value.locates
        let locatable = AnyLocatable(section: indexPath.section, week: model.value.inDay, location: locate.lowerBound)
        let list = map.pointMap[locatable]?.count ?? 1
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCollectionViewCell.reuseIdentifier, for: indexPath) as! ContentCollectionViewCell
        
        cell.title = model.value.course
        cell.content = "\(indexPath.section)-\(model.value.inDay)-\(locate.lowerBound)"
        cell.isMulty = (list > 1)
        cell.oneLenth = (locate.count == 1)
        switch model.kind {
        case .mine:
            if locate.lowerBound <= 4 {
                cell.drawType = .morning
            } else if locate.lowerBound <= 8 {
                cell.drawType = .afternoon
            } else if locate.lowerBound <= 12 {
                cell.drawType = .night
            }
        case .custom:
            cell.drawType = .custom
        case .others:
            cell.drawType = .others
        }
        
        return cell
    }
    
    // MARK: CollectionViewLayoutDataSource
    
    open func collectionView(_ collectionView: UICollectionView, persentFor indexPath: IndexPath) -> CGFloat {
        1
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CollectionViewLayout, locationForItemAt indexPath: IndexPath) -> AnyLocatable {
        let value = map.final[indexPath.section][indexPath.item]
        return AnyLocatable(section: indexPath.section, week: value.model.value.inDay, location: value.locates.lowerBound)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CollectionViewLayout, lenthLocate locate: AnyLocatable, at indexPath: IndexPath) -> Int {
        map.final[indexPath.section][indexPath.item].locates.count
    }
    
    // MARK: TEST
    
    public func request(response: @escaping () -> Void) {
        map.sno = "2021215154"
        
        Request.request(attributes: [
            .dataRequest(.student("2021215154")),
            .dataRequest(.student("2022212832"))
        ]) { responses in            
            for response in responses {
                switch response {
                case .success(let item):
                    self.map.insert(item: item)
                case .failure(let error):
                    break
                }
            }
            
            response()
        }
    }
}
