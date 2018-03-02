//
//  WKViewControllerTransition.swift
//  WashHelper
//
//  Created by yzl on 18/2/3.
//  Copyright © 2018年 lwk. All rights reserved.
//

import UIKit

enum WKTransitionType {
    case show
    case dismiss
}

class WKViewControllerTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    private var transitionType: WKTransitionType!
    
    private var complete: (()->Void)?
    
    static internal func transition(for type: WKTransitionType, completion: (()->Void)?) -> WKViewControllerTransition {
        let t = WKViewControllerTransition(type)
        t.complete = completion
        return t
    }
    
    private init(_ type: WKTransitionType) {
        transitionType = type
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if transitionType == .show {
            animateTransitionForShow(using: transitionContext)
        }
        else {
            animateTransitionForDismiss(using: transitionContext)
        }
    }
    
    private func animateTransitionForShow(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? WKPictureBrowserViewController else {
            return
        }
        guard let fromVC = transitionContext.viewController(forKey: .from) else {
            return
        }
        guard let fromView = toVC.fromView else {
            return
        }
        
        let containerView = transitionContext.containerView
        toVC.view.alpha = 0
        containerView.addSubview(toVC.view)
        toVC.view.frame = fromView.convert(fromView.bounds, to: containerView)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            toVC.view.frame = fromVC.view.bounds
            toVC.view.alpha = 1.0
        }) { (finished) in
            transitionContext.completeTransition(true)
            if let handler = self.complete {
                handler()
            }
        }
    }
    
    private func animateTransitionForDismiss(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        guard let fromVC = transitionContext.viewController(forKey: .from) as? WKPictureBrowserViewController else {
            return
        }
        guard let fromView = fromVC.fromView else {
            return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toVC.view)
        
        let convertFrame = fromView.convert(fromView.bounds, to: containerView)
        let fromFrame = fromVC.pictureBroswer.currentPictureView!.imageView.convert(fromVC.pictureBroswer.currentPictureView!.imageView.bounds, to: containerView)
        let imageView = UIImageView(frame: fromFrame)
        imageView.image = fromVC.pictureBroswer.currentPictureView!.imageView.image
        containerView.addSubview(imageView)
        fromVC.pictureBroswer.currentPictureView!.isHidden = true
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                       animations: {
                            fromVC.view.alpha = 0.0
                            imageView.alpha = 0.3
                            imageView.frame = convertFrame
                        }) { (finished) in
                            imageView.isHidden = true
                            imageView.removeFromSuperview()
                            transitionContext.completeTransition(true)
                            if let handler = self.complete {
                                handler()
                            }
                        }
    }

}
