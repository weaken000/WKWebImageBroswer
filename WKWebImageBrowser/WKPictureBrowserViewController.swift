//
//  WKPictureBroswerViewController.swift
//  WashHelper
//
//  Created by yzl on 18/2/3.
//  Copyright © 2018年 lwk. All rights reserved.
//

import UIKit

public class WKPictureBrowserViewController: UIViewController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {

    internal var fromView: UIView?

    internal var pictureBroswer: WKWebImageBrowser!
    
    private let urls: [String]
    
    private let index: Int

    init?(urls: [String], index: Int = 0, fromView: UIView?) {
        self.fromView = fromView
        
        if urls.isEmpty {
            return nil
        }
        
        if index >= urls.count {
            return nil
        }
        
        self.urls = urls
        self.index = index
        
        super.init(nibName: nil, bundle: nil)
        
        self.transitioningDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func setupBroswer() {
        
        let statusH = UIApplication.shared.statusBarFrame.size.height
        pictureBroswer = WKWebImageBrowser(frame: CGRect(x: 0, y: statusH, width: view.frame.size.width, height: view.frame.size.height - statusH), urls: urls, currentIndex: index)
        view.addSubview(pictureBroswer)
        pictureBroswer.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        pictureBroswer.handlerGesture = { [weak self] (gesture) in
            if let `self` = self {
                return self.handleGesture(gesture)
            }
            return false
        }
        pictureBroswer.handlerDismissAction = { [weak self] in
            if let `self` = self {
                if let navi = self.navigationController {
                    _ = navi.popViewController(animated: true)
                }
                else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func handleGesture(_ gesture: UIPanGestureRecognizer) -> Bool {
        let y = max(0.0, gesture.translation(in: gesture.view).y - 40.0)
        var percent = y / (view.frame.size.height * 0.25)
        percent = min(1.0, percent)
        switch gesture.state {
        case .ended, .cancelled:
            if percent > 0.5 {
                if let navi = self.navigationController {
                    _ = navi.popViewController(animated: true)
                }
                else {
                    self.dismiss(animated: true, completion: nil)
                }
                return true
            }
        default:
            break
        }
        return false
    }
    
    //MARK: UIViewControllerTransitioningDelegate
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromView != nil {
            let transition = WKViewControllerTransition.transition(for: .show, completion: {
                self.setupBroswer()
            })
            return transition
        }
        setupBroswer()
        return nil
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromView != nil {
            return WKViewControllerTransition.transition(for: .dismiss, completion: nil)
        }
        return nil
    }
    
    //MARK: UINavigationControllerDelegate
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .push {
            if fromView != nil {
                return WKViewControllerTransition.transition(for: .show, completion: {
                    self.setupBroswer()
                })
            }
            setupBroswer()
            return nil
        }
        
        if fromView != nil {
           return WKViewControllerTransition.transition(for: .dismiss, completion: nil)
        }
        return nil
    }
    
}
