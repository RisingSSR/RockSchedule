//
//  VCTransitioningDelegate.swift
//  RockSchedule
//
//  Created by SSR on 2023/6/7.
//

import UIKit

open class VCTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    public var transitionDurationIfNeeded: TimeInterval = 0.3
    
    public var supportedTapOutsideBackWhenPresent: Bool = true
    
    public weak var panGestureIfNeeded: UIPanGestureRecognizer?
    
    public var panInsetsIfNeeded: UIEdgeInsets = .zero
    
    // Animation Supported
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = PresentVCAnimatedTransition()
        transition.transitionDuration = transitionDurationIfNeeded
        transition.supportedTapOutsideBack = supportedTapOutsideBackWhenPresent
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = DismissVCAnimatedTransition()
        transition.transitionDuration = transitionDurationIfNeeded
        return transition
    }
    
    // Interactive Supported
    
    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let panGestureIfNeeded else { return nil }
        let transition = PresentDrivenInteractiveTransition(panGesture: panGestureIfNeeded)
        transition.panInsets = panInsetsIfNeeded
        return transition
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let panGestureIfNeeded else { return nil }
        let transition = DismissDrivenInteractiveTransition(panGesture: panGestureIfNeeded)
        transition.panInsets = panInsetsIfNeeded
        return transition
    }

}
