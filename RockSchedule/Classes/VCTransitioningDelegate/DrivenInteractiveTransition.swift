//
//  DrivenInteractiveTransition.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/7.
//

import UIKit

// MARK: DrivenInteractiveTransition

open class DrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
    
    public var panInsets: UIEdgeInsets = .zero
    
    public var contextSafeBottom: CGFloat {
        context.containerView.frame.size.height - panInsets.bottom
    }
    
    public var contextSafeRight: CGFloat {
        context.containerView.frame.size.width - panInsets.right
    }
    
    private var context: UIViewControllerContextTransitioning!
    
    public init(panGesture: UIPanGestureRecognizer) {
        super.init()
        panGesture.addTarget(self, action: #selector(DrivenInteractiveTransition.update(pan:)))
    }
    
    open func percent(pan: UIPanGestureRecognizer, context: UIViewControllerContextTransitioning) -> CGFloat {
        .zero
    }
    
    open func finish(ended pan: UIPanGestureRecognizer, context: UIViewControllerContextTransitioning) -> Bool {
        percent(pan: pan, context: context) >= 0.3
    }
    
    open override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
        context = transitionContext
    }
    
    @objc private func update(pan: UIPanGestureRecognizer) {
        let percent = percent(pan: pan, context: context)
        switch pan.state {
        case .began: break
        case .changed:
            update(percent)
        case .ended:
            if finish(ended: pan, context: context) {
                finish()
            } else {
                cancel()
            }
        default:
            cancel()
        }
    }

}

// MARK: PresentDrivenInteractiveTransition

open class PresentDrivenInteractiveTransition: DrivenInteractiveTransition {
    
    open override func percent(pan: UIPanGestureRecognizer, context: UIViewControllerContextTransitioning) -> CGFloat {
        let point = pan.location(in: context.containerView)
        if point.y >= contextSafeBottom { return 0 }
        if point.y <= self.panInsets.top { return 1 }
        let fullH = contextSafeBottom - panInsets.top
        let onH = contextSafeBottom - point.y
        return onH / fullH
    }
    
    open override func finish(ended pan: UIPanGestureRecognizer, context: UIViewControllerContextTransitioning) -> Bool {
        super.finish(ended: pan, context: context)
    }
}

// MARK: DismissDrivenInteractiveTransition

open class DismissDrivenInteractiveTransition: DrivenInteractiveTransition {
    
    open override func percent(pan: UIPanGestureRecognizer, context: UIViewControllerContextTransitioning) -> CGFloat {
        let point = pan.location(in: context.containerView)
        if point.y >= contextSafeBottom { return 1 }
        if point.y <= panInsets.top { return 0 }
        let fullH = contextSafeBottom - panInsets.top
        let onH = point.y - panInsets.top
        return onH / fullH
    }
    
    open override func finish(ended pan: UIPanGestureRecognizer, context: UIViewControllerContextTransitioning) -> Bool {
        super.finish(ended: pan, context: context)
    }
}
