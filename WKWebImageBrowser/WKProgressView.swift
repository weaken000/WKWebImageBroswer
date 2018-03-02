//
//  WKProgressView.swift
//  WashHelper
//
//  Created by yzl on 18/1/23.
//  Copyright © 2018年 lwk. All rights reserved.
//

import UIKit

class WKProgressView: UIView {

    fileprivate var progressLayer: CAShapeLayer!
    
    private var circleLayer: CAShapeLayer!
    
    private var progress: CGFloat = 0.0
   
    override init(frame: CGRect) {
        
        progressLayer = CAShapeLayer()
        circleLayer = CAShapeLayer()
        
        super.init(frame: frame)
        
        setupLayer()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayer() {
        let center = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        let radius = min(self.frame.size.width, self.frame.size.height) / 2.0 - 5.0
        
        let circelPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: radius*2.0, height: radius*2.0))
        circleLayer.path = circelPath.cgPath
        circleLayer.lineWidth = 2.0
        circleLayer.strokeColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.6).cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.position = center
        circleLayer.bounds = CGRect(x: 0, y: 0, width: radius*2.0, height: radius*2.0)
        self.layer.addSublayer(circleLayer)
        
        let progressRadius = radius - 3.0
        let progressPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: progressRadius, height: progressRadius))
        progressLayer.path = progressPath.cgPath
        progressLayer.lineWidth = progressRadius
        progressLayer.strokeColor = UIColor(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0, alpha: 0.6).cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.position = center
        progressLayer.bounds = CGRect(x: 0, y: 0, width: progressRadius, height: progressRadius)
        progressLayer.strokeEnd = progress
        progressLayer.transform = CATransform3DMakeRotation(-(CGFloat)(M_PI_2), 0, 0, 1)
        self.layer.addSublayer(progressLayer)
    }
    
    internal func config(progress: Double) {
        
        if self.progress == CGFloat(progress) {
            return
        }
    
        self.progress = CGFloat(progress)
        
        if self.progress == 1.0 {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = progressLayer.strokeEnd
            anim.toValue = 1.0
            anim.duration = 0.2
            anim.isRemovedOnCompletion = false
            anim.fillMode = kCAFillModeForwards
            anim.delegate = self
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            progressLayer.add(anim, forKey: nil)
        }
        else {
            self.isHidden = false
            progressLayer.strokeEnd = self.progress
        }
 
    }
}

extension WKProgressView: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            self.isHidden = true
            progressLayer.strokeEnd = 0.0
            progressLayer.removeAllAnimations()
        }
    }
}
