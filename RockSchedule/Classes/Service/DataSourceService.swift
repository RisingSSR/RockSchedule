//
//  DataSourceService.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/2.
//

import UIKit
 
open class DataSourceService: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, CollectionViewLayoutDataSource {
    
    public private(set) var map = FinalMap(keyFetal: .double)
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
        view.register(SupplyCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.header, withReuseIdentifier: SupplyCollectionViewCell.reuseIdentifier)
        view.register(SupplyCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.leading, withReuseIdentifier: SupplyCollectionViewCell.reuseIdentifier)

        return view
    }
    
    // MARK: UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return max(map.final.count, 24)
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section >= map.final.count { return 0 }
        return map.final[section].values.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let value = map.final[indexPath.section].values[indexPath.item]
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
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.header {
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SupplyCollectionViewCell.reuseIdentifier, for: indexPath) as! SupplyCollectionViewCell
            cell.backgroundColor = collectionView.backgroundColor
            cell.isCurrent = false
            
            if indexPath.section <= map.final.count, indexPath.section != 0,
               let startDate = map.final[indexPath.section].startDate {
                
                let date = startDate.reset(.weekday, value: (indexPath.item + 7) % 7 + 1)
                if indexPath.item == 0 {
                    cell.title(indexPath.section == 0 ? "学期" : date?.string(withFormat: "M月"))
                } else {
                    cell.title(date?.string(withFormat: "EE", locale: .zh_CN), content: .content(date?.string(withFormat: "d日")))
                    cell.isCurrent = (indexPath.section == map.nowWeek && date == Date())
                }
                
            } else {
                if indexPath.item == 0 {
                    cell.title(indexPath.section == 0 ? "学期" : "\(indexPath.section)周")
                } else {
                    if let date = Date().reset(.weekday, value: (indexPath.item + 7) % 7 + 1) {
                        cell.title(date.string(withFormat: "EE", locale: .zh_CN))
                    }
                }
            }
            return cell
            
        } else if kind == UICollectionView.leading {
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SupplyCollectionViewCell.reuseIdentifier, for: indexPath) as! SupplyCollectionViewCell
            var timeline: TimeLine!
            if indexPath.section <= map.final.count {
                timeline = .init(special: [])
            } else {
                timeline = .init(special: map.final[indexPath.section].specialTime)
            }
            let layout = TimeLine[timeline.layouts[indexPath.item]].layout
            switch layout {
            case .normal(let i):
                cell.title("\(i)")
            case .special(let s):
                cell.title("\(s.description.replacingOccurrences(of: "", with: "\n").trimmingCharacters(in: .whitespacesAndNewlines))")
            }
            
            return cell
        }
        
        fatalError("without kind \(kind)")
    }
    
    // MARK: CollectionViewLayoutDataSource
    
    open func collectionView(_ collectionView: UICollectionView, numberOfSupplementaryOf kind: String, in section: Int) -> Int {
        if kind == UICollectionView.header { return 8 }
        if kind == UICollectionView.leading {
            if map.final.count <= section {
                return TimeLine(special: []).count
            } else {
                return TimeLine(special: map.final[section].specialTime).count
            }
        }
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, persentFor indexPath: IndexPath) -> CGFloat {
        1
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CollectionViewLayout, locationForItemAt indexPath: IndexPath) -> AnyLocatable {
        let value = map.final[indexPath.section].values[indexPath.item]
        let locatable = AnyLocatable(section: indexPath.section, week: value.model.value.inDay, location: value.locates.lowerBound)
        var location = locatable.location
        if locatable.location >= 5, !map.final[indexPath.section].specialTime.contains(.noon) {
            location -= 1
        }
        if locatable.location >= 9, !map.final[indexPath.section].specialTime.contains(.night) {
            location -= 1
        }
        return AnyLocatable(section: locatable.section, week: locatable.week, location: location)
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CollectionViewLayout, lenthLocate locate: AnyLocatable, at indexPath: IndexPath) -> Int {
        let value = map.final[indexPath.section].values[indexPath.item]
        let locatable = AnyLocatable(section: indexPath.section, week: value.model.value.inDay, location: value.locates.lowerBound)
        var count = map.final[indexPath.section].values[indexPath.item].locates.count
        if locatable.location >= 5, !map.final[indexPath.section].specialTime.contains(.noon) {
            count -= 1
        }
        if locatable.location >= 9, !map.final[indexPath.section].specialTime.contains(.night) {
            count -= 1
        }
        return count
    }
    
    // MARK: UIScrollViewDelegate
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let layout = (scrollView as? UICollectionView)?.collectionViewLayout as? CollectionViewLayout {
            layout.pageCalculation = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            _scrollViewStartPosPoint = scrollView.contentOffset
            _scrollDirection = 0
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if _scrollDirection == 0 {
            if abs(_scrollViewStartPosPoint.x - scrollView.contentOffset.x) < abs(_scrollViewStartPosPoint.y - scrollView.contentOffset.y) {
                _scrollDirection = 1    // Vertical Scrolling
            } else {
                _scrollDirection = 2    // Horitonzal Scrolling
            }
        }
        // Update scroll position of the scrollview according to detected direction.
        if _scrollDirection == 1 {
            scrollView.contentOffset = CGPoint(x: _scrollViewStartPosPoint.x, y: scrollView.contentOffset.y)
        } else if _scrollDirection == 2 {
            scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: _scrollViewStartPosPoint.y)
        }
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate { _scrollDirection = 0 }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        _scrollDirection = 0
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
