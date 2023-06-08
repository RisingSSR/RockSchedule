//
//  CollectionViewLayout.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/2.
//

import UIKit

public extension UICollectionView {
    static let header: String = "header"
    static let leading: String = "leading"
    static let placehoder: String = "placehoder"
    static let pointer: String = "pointer"
}

@objc
public protocol CollectionViewLayoutDataSource: NSObjectProtocol {
    
    @objc optional
    func collectionView(_ collectionView: UICollectionView, numberOfSupplementaryOf kind: String, in section: Int) -> Int
    
    @objc
    func collectionView(_ collectionView: UICollectionView, persentFor indexPath: IndexPath) -> CGFloat
    
    @objc
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CollectionViewLayout, locationForItemAt indexPath: IndexPath) -> AnyLocatable
    
    @objc
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: CollectionViewLayout, lenthLocate locate: AnyLocatable, at indexPath: IndexPath) -> Int
}

open class CollectionViewLayout: UICollectionViewLayout {
    
    open class InvalidationContext: UICollectionViewLayoutInvalidationContext {
        var header: Bool = true
        var leading: Bool = false
        var placehoder: Bool = true
        var pointer: Bool = true
    }
    
    weak public var dataSource: CollectionViewLayoutDataSource?
    
    public var lineSpacing: CGFloat
    
    public var columnSpacing: CGFloat
    
    public var widthForLeadingSupplementaryView: CGFloat
    
    public var heightForHeaderSupplementaryView: CGFloat
    
    public var numberOfPages: Int
    
    public var pageCalculation: Int
    
    public var ratio: CGFloat
    public private(set) var itemSize: CGSize
    
    public private(set) var itemCache: [IndexPath: UICollectionViewLayoutAttributes]
    public private(set) var suplyCache: [String: [IndexPath: UICollectionViewLayoutAttributes]]
    public private(set) var sections: Int
    
    private var numberOfTimeLine: Int?
    
    override public init() {
        itemCache = [:]
        suplyCache = [
            UICollectionView.header: [:],
            UICollectionView.leading: [:],
            UICollectionView.placehoder: [:],
            UICollectionView.pointer: [:]
        ]
        lineSpacing = 2
        columnSpacing = 2
        widthForLeadingSupplementaryView = 30
        heightForHeaderSupplementaryView = 0
        pageCalculation = 0
        itemSize = .zero
        sections = 0
        numberOfPages = 1
        ratio = 50.0 / 46.0
        super.init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Ask LayoutAttributes
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var result = [UICollectionViewLayoutAttributes]()
        numberOfTimeLine = 0
        
        for s in max(pageCalculation - 1, 0)...min(pageCalculation + numberOfPages, sections) {
            for (kind, _) in suplyCache {
                numberOfTimeLine = dataSource?.collectionView?(collectionView!, numberOfSupplementaryOf: kind, in: s)
                let suplyCount = numberOfTimeLine ?? 0
                for i in 0..<suplyCount {
                    let indexPath = IndexPath(item: i, section: s)
                    if let attributes = self.layoutAttributesForSupplementaryView(ofKind: kind, at: indexPath) {
                        if rect.intersects(attributes.frame) {
                            result.append(attributes)
                        }
                    }
                }
            }
            
            let itemCount = collectionView?.dataSource?.collectionView(collectionView!, numberOfItemsInSection: s) ?? collectionView?.numberOfItems(inSection: s) ?? 0
            for i in 0..<itemCount {
                let indexPath = IndexPath(item: i, section: s)
                if let attributes = self.layoutAttributesForItem(at: indexPath) {
                    if rect.intersects(attributes.frame) {
                        result.append(attributes)
                    }
                }
            }
        }
        return result
    }
    
    open override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if suplyCache[elementKind] == nil { suplyCache[elementKind] = [:] }
        if suplyCache[elementKind]![indexPath] == nil {
            suplyCache[elementKind]![indexPath] = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        }
        let attributes = suplyCache[elementKind]![indexPath]!
        
        remake(attributes: attributes)
        
        return attributes
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if itemCache[indexPath] == nil {
            itemCache[indexPath] = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        }
        let attributes = itemCache[indexPath]!
        
        remake(attributes: attributes)
        
        return attributes
    }
    
    private func remake(attributes: UICollectionViewLayoutAttributes) {
        let indexPath = attributes.indexPath
        switch attributes.representedElementCategory {
        case .cell:
            if let locate = dataSource?.collectionView(collectionView!, layout: self, locationForItemAt: indexPath) {
                let x = CGFloat(locate.section) * (collectionView?.frame.width ?? 0) + widthForLeadingSupplementaryView + CGFloat(locate.week - 1) * (itemSize.width + columnSpacing)
                let y = heightForHeaderSupplementaryView + CGFloat(locate.location - 1) * (itemSize.height + lineSpacing)
                let lenth = dataSource?.collectionView(collectionView!, layout: self, lenthLocate: locate, at: indexPath) ?? 0
                let height = CGFloat(lenth) * itemSize.height + CGFloat(lenth - 1) * columnSpacing
                let frame = CGRect(x: x, y: y, width: itemSize.width, height: height)
                attributes.frame = frame
                return
            }
            return
        case .supplementaryView:
            if case let .some(kind) = attributes.representedElementKind  {
                switch kind {
                case UICollectionView.header, UICollectionView.elementKindSectionHeader:
                    if indexPath.item == 0 {
                        let x = CGFloat(indexPath.section) * (collectionView?.frame.width ?? 0)
                        let y = collectionView?.contentOffset.y ?? 0
                        let frame = CGRect(x: x, y: y, width: widthForLeadingSupplementaryView, height: heightForHeaderSupplementaryView)
                        attributes.frame = frame
                        attributes.zIndex = 10
                        return
                    }
                    let x = CGFloat(indexPath.section) * (collectionView?.frame.width ?? 0) + widthForLeadingSupplementaryView + CGFloat(indexPath.item - 1) * (columnSpacing + itemSize.width)
                    let y = collectionView?.contentOffset.y ?? 0
                    let frame = CGRect(x: x, y: y, width: itemSize.width, height: heightForHeaderSupplementaryView)
                    attributes.frame = frame
                    attributes.zIndex = 10
                    return
                case UICollectionView.leading:
                    let x = CGFloat(indexPath.section) * (collectionView?.frame.width ?? 0)
                    let y = heightForHeaderSupplementaryView + CGFloat(indexPath.item) * (lineSpacing + itemSize.height)
                    let frame = CGRect(x: x, y: y, width: widthForLeadingSupplementaryView, height: itemSize.height)
                    attributes.frame = frame
                    return
                case UICollectionView.placehoder:
                    let x = CGFloat(indexPath.section) * (collectionView?.frame.width ?? 0) + widthForLeadingSupplementaryView
                    let y = collectionView?.contentOffset.y ?? 0
                    let width = (collectionView?.frame.width ?? 0) - widthForLeadingSupplementaryView
                    let height = (collectionView?.frame.height ?? 0) - heightForHeaderSupplementaryView
                    let frame = CGRect(x: x, y: y, width: width, height: height)
                    attributes.frame = frame
                    return
                case UICollectionView.pointer:
                    let x = CGFloat(indexPath.section) * (collectionView?.frame.width ?? 0)
                    let width = widthForLeadingSupplementaryView
                    let size = CGSize(width: width, height: width / 28 * 6)
                    let frame = CGRect(origin: CGPoint(x: x, y: .nan), size: size)
                    let persent = dataSource?.collectionView(collectionView!, persentFor: indexPath) ?? 0
                    let centerY: CGFloat!
                    if persent >= 0 {
                        centerY = heightForHeaderSupplementaryView + CGFloat(persent / 1 - 1) * (lineSpacing + itemSize.height) + itemSize.height * persent.truncatingRemainder(dividingBy: 1)
                    } else {
                        centerY = heightForHeaderSupplementaryView + itemSize.height + CGFloat(-persent / 1 - 1) * (lineSpacing + itemSize.height) + lineSpacing * (-persent).truncatingRemainder(dividingBy: 1)
                    }
                    attributes.frame = frame
                    attributes.center.y = centerY
                    attributes.zIndex = 5
                    return
                default:
                    return
                }
            }
            return
        default:
            return
        }
    }
    
    open override func prepare() {
        let collectionViewWidth = collectionView?.bounds.width ?? 0
        let itemWidth =  ((collectionViewWidth / CGFloat(numberOfPages)) - widthForLeadingSupplementaryView) / 7 - columnSpacing
        
        itemSize = CGSizeMake(itemWidth, itemWidth * ratio);
    }
    
    // MARK: UISubclassingHooks
    
    open override class var layoutAttributesClass: AnyClass { UICollectionViewLayoutAttributes.self }
    
    open override class var invalidationContextClass: AnyClass { InvalidationContext.self }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { true }
    
    open override var collectionViewContentSize: CGSize {
        let width = CGFloat(sections) * (collectionView?.bounds.width ?? 0)
        let height = heightForHeaderSupplementaryView + CGFloat(numberOfTimeLine ?? 13) * (itemSize.height + lineSpacing)
        return CGSize(width: width, height: height)
    }
    
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let toTime = (collectionView?.contentOffset.y ?? 0) / (itemSize.height + lineSpacing) + 0.5
        let toY = (itemSize.height + lineSpacing) * toTime
        var index: Int = Int(proposedContentOffset.x / (collectionView?.bounds.width ?? 1) + 0.5)
        let remainder = proposedContentOffset.x - CGFloat(index) * (collectionView?.bounds.width ?? 0)
        if velocity.x > 0.5 || (velocity.x > 0.3 && remainder > (collectionView?.bounds.width ?? 0) / 3) {
            index += 1
        }
        if velocity.x < -0.5 || (velocity.x < -0.3 && remainder < (collectionView?.bounds.width ?? 0) / 3 * 2) {
            index -= 1
        }
        index = max(index, pageCalculation - 1)
        index = min(index, pageCalculation + 1)
        let toX = (collectionView?.bounds.width ?? 0) * CGFloat(index)
        return CGPoint(x: toX, y: toY)
    }
    
    open override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        super.invalidateLayout(with: context)
        if context.invalidateDataSourceCounts {
            sections = collectionView?.dataSource?.numberOfSections?(in: collectionView!) ?? collectionView?.numberOfSections ?? 0
            for (k, _) in suplyCache { suplyCache[k]!.removeAll() }
        }
        
        if let context = context as? InvalidationContext {
            if context.header {
                suplyCache[UICollectionView.header]?.forEach({ remake(attributes: $0.value) })
            }
            if context.pointer {
                suplyCache[UICollectionView.pointer]?.forEach({ remake(attributes: $0.value) })
            }
            if context.placehoder {
                suplyCache[UICollectionView.placehoder]?.forEach({ remake(attributes: $0.value) })
            }
            if context.leading {
                suplyCache[UICollectionView.leading]?.forEach({ remake(attributes: $0.value) })
            }
        }
    }
}
