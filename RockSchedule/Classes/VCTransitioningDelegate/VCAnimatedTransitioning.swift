//
//  VCAnimatedTransitioning.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/7.
//

import UIKit

public extension UIViewController {
    @objc func dismissAnimated() {
        dismiss(animated: true)
    }
}

// MARK: VCAnimatedTransitioning

open class VCAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    public var transitionDuration: TimeInterval = 0.3
    
    open func prepare(animate context: UIViewControllerContextTransitioning) { }
    
    open func finished(animate context: UIViewControllerContextTransitioning) { }
    
    open func completion(_ context: UIViewControllerContextTransitioning) {
        context.completeTransition(!context.transitionWasCancelled)
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        prepare(animate: transitionContext)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveLinear) {
            self.finished(animate: transitionContext)
        } completion: { finished in
            self.completion(transitionContext)
        }
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionDuration
    }
}

// MARK: PresentVCAnimatedTransition

open class PresentVCAnimatedTransition: VCAnimatedTransitioning {
    
    public var supportedTapOutsideBack: Bool = true
    
    open override func prepare(animate context: UIViewControllerContextTransitioning) {
        let from = context.viewController(forKey: .from)
        let to = context.viewController(forKey: .to)
        
        from?.beginAppearanceTransition(false, animated: true)
        
        var beginFrame = to?.view.frame ?? .zero
        beginFrame.origin.y = context.containerView.frame.origin.y + context.containerView.frame.size.height;
        
        to?.view.frame = beginFrame
        if let toView = to?.view {
            context.containerView.addSubview(toView)
        }
    }
    
    open override func finished(animate context: UIViewControllerContextTransitioning) {
        let to = context.viewController(forKey: .to)
        var endFrame = to?.view.frame ?? .zero
        endFrame.origin.y = context.containerView.frame.size.height - endFrame.size.height
        to?.view.frame = endFrame
    }
    
    open override func completion(_ context: UIViewControllerContextTransitioning) {
        let to = context.viewController(forKey: .to)
        if context.transitionWasCancelled {
            to?.view.removeFromSuperview()
        } else {
            if self.supportedTapOutsideBack, let to {
                to.dismiss(animated: true)
                let tap = UITapGestureRecognizer(target: to, action: #selector(UIViewController.dismissAnimated))
                context.containerView.addGestureRecognizer(tap)
            }
        }
        super.completion(context)
    }
}

// MARK: DismissVCAnimatedTransition

open class DismissVCAnimatedTransition: VCAnimatedTransitioning {
    
    open override func prepare(animate context: UIViewControllerContextTransitioning) {
        let from = context.viewController(forKey: .from)
        let to = context.viewController(forKey: .to)
        
        from?.beginAppearanceTransition(false, animated: true)
        to?.beginAppearanceTransition(true, animated: true)
    }
    
    open override func finished(animate context: UIViewControllerContextTransitioning) {
        let from = context.viewController(forKey: .from)
        
        var endFrame = from?.view.frame ?? .zero
        endFrame.origin.y = context.containerView.frame.origin.y + context.containerView.frame.size.height
        
        from?.view.frame = endFrame
    }
    
    open override func completion(_ context: UIViewControllerContextTransitioning) {
        let from = context.viewController(forKey: .from)
        if !context.transitionWasCancelled {
            from?.view.removeFromSuperview()
        }
        super.completion(context)
    }
}
