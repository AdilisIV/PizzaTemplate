//
//  Transitions.swift
//  Pizza
//
//  Created by Alexander Kosse on 23/11/2017.
//  Copyright © 2017 Information Technologies, LLC. All rights reserved.
//

import UIKit

class PushTransitionManager : NSObject, UIViewControllerAnimatedTransitioning {
    let animationDuration = 0.35
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        
        let finalFrame  = containerView.bounds
        let initalFrame = CGRect(x: 0, y: -finalFrame.height, width: finalFrame.width, height: finalFrame.height)
        
        toView.frame = initalFrame
        UIView.animate(withDuration: animationDuration,
                       animations: { toView.frame = finalFrame },
                       completion: { finished in transitionContext.completeTransition(finished)
        })
    }
}

class PopTransitionManager : NSObject, UIViewControllerAnimatedTransitioning {
    let animationDuration = 0.35
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        
        let initalFrame = containerView.bounds
        let finalFrame  = CGRect(x: 0, y: -initalFrame.height, width: initalFrame.width, height: initalFrame.height)
        
        fromView.frame = initalFrame
        UIView.animate(withDuration: animationDuration,
                       animations: { fromView.frame = finalFrame },
                       completion: { finished in transitionContext.completeTransition(finished) })
    }
}

class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push && toVC is CategoryController {
            return PushTransitionManager()
        }
        if operation == .pop && fromVC is CategoryController {
            return PopTransitionManager()
        }
        return nil
    }
}

