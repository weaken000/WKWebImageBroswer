//
//  WKLoadImageErrorView.swift
//  WKWebImageBrowserExample
//
//  Created by mc on 2018/3/14.
//  Copyright © 2018年 lwk. All rights reserved.
//

import UIKit

class WKLoadImageErrorView: UIView {

    
    init(frame: CGRect, shouldTapReload: Bool = false) {
        
        self.shouldTapReload = shouldTapReload
        super.init(frame: frame)
        
        if shouldTapReload {
            let tapper = UITapGestureRecognizer(target: self, action: #selector(tap_reload(gesture:)))
            addGestureRecognizer(tapper)
        }
        errorImageLayer.isHidden = false
        descriptionLayer.isHidden = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        
        
        
    }
    
    //MARK: Public
    public func showError(errorImage: UIImage?, desc: String?) {
//        if self.isHidden == false {
//            return
//        }
        
        self.isHidden = false
        
        if let errorImage = errorImage {
            errorImageLayer.contents = errorImage.cgImage
        }
        if let desc = desc {
            descriptionLayer.string = desc
        }
        
    }
    
    public func hiddenErrorView() {
        self.isHidden = true
    }
    
    //MARK: Action
    @objc private func tap_reload(gesture: UITapGestureRecognizer) {
        
    }
    
    //MARK: Property
    private let shouldTapReload: Bool
    
    private lazy var descriptionLayer: CATextLayer = {
        let layer = CATextLayer()
        layer.foregroundColor = UIColor.white.cgColor
        layer.font = "HiraKakuProN-W3" as CFTypeRef
        layer.fontSize = 17
        layer.string = "图片加载失败"
        layer.alignmentMode = kCAAlignmentCenter
        layer.isWrapped = true
        self.layer.addSublayer(layer)
        
        layer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: 200)
        layer.position = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0+170.0)
        
        return layer
    }()
    
    private lazy var errorImageLayer: CALayer = {
        let layer = CALayer()
        layer.contentsGravity = kCAGravityResizeAspect
        layer.contents = UIImage(named: "error.png")?.cgImage
        self.layer.addSublayer(layer)
        
        layer.frame = CGRect(x: 0, y: 0, width: 200.0, height: 200.0)
        layer.position = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0 - 60.0)
        
        return layer
    }()
    
}
