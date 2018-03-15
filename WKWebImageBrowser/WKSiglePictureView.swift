//
//  WKSiglePictureView.swift
//  WashHelper
//
//  Created by yzl on 18/1/23.
//  Copyright © 2018年 lwk. All rights reserved.
//

import UIKit

public protocol WKSiglePictureViewDelegate: NSObjectProtocol {
    func siglePictureView(_ pictureView: WKSiglePictureView, didPanEnd gesture: UIPanGestureRecognizer) -> Bool
}

public class WKSiglePictureView: UIView {

    internal let scrollView: UIScrollView
    internal let imageView: UIImageView
    internal var indexX = 0
    internal weak var delegate: WKSiglePictureViewDelegate?
    internal var loadErrorView: WKLoadImageErrorView?
    
    private var progressView: WKProgressView?
    private var originFrame: CGRect?
    fileprivate var isInDismiss: Bool = false
    fileprivate var panGesture: UIPanGestureRecognizer!
    
    internal var imageData: WKImageData? {
        didSet {
            
            loadErrorView?.hiddenErrorView()

            if let newData = imageData {
                
                if let image = newData.image {
                    aspectFitImage(image: image)
                }
                else {
                    progressView?.config(progress: 3.0 / 360.0)
                    imageView.wk.setImage(url: URL(string: newData.url), placeHolder: nil, progress: { [weak self] (percent) in
                        if let `self` = self {
                            self.progressView?.config(progress: percent)
                        }
                    }, completion: { [weak self] (image, error) in
                        
                        if let `self` = self {
                            
                            self.progressView?.isHidden = true

                            //适配图片
                            if let `image` = image {
                                self.aspectFitImage(image: image)
                                return
                            }
                            
                            //显示错误信息
                            if let _ = error {
                                
                                if let errorView = self.loadErrorView {
                                    errorView.showError(errorImage: nil, desc: nil)
                                }
                                else {
                                    self.loadErrorView = WKLoadImageErrorView(frame: self.bounds, shouldTapReload: false)
                                    self.addSubview(self.loadErrorView!)
                                    self.loadErrorView?.showError(errorImage: nil, desc: nil)
                                }
                                
                            }
                            
                        }
                    })
                }
            }
        }
    }
    
    
    
    override init(frame: CGRect) {
        
        scrollView = UIScrollView()
        imageView = UIImageView()
        
        super.init(frame: frame)
        
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        setupSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        
        progressView?.center = CGPoint(x: frame.size.width/2.0, y: frame.size.height/2.0)
        scrollView.frame = bounds
        scrollView.contentSize = frame.size
        
        super.layoutSubviews()
    }
    
    private func setupSubviews() {
        
        imageView.frame = scrollView.bounds
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2.0
        scrollView.minimumZoomScale = 0.5
        
        progressView = WKProgressView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        progressView?.center = CGPoint(x: frame.size.width/2.0, y: frame.size.height/2.0)
        progressView?.isHidden = true
        addSubview(progressView!)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.dismiss(_:)))
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }
    
    private func aspectFitImage(image: UIImage?) {
        
        guard let `image` = image else {
            imageView.image = nil
            imageView.frame = self.bounds
            originFrame = imageView.frame
            return
        }
    
        let scale = min(frame.size.width / image.size.width, frame.size.height / image.size.height)
        let w = scale * image.size.width
        let h = scale * image.size.height
        imageView.frame = CGRect(x: (frame.size.width - w) / 2.0, y: (frame.size.height - h) / 2.0, width: w, height: h)
        imageView.image = image
        originFrame = imageView.frame
        imageData?.image = image
        
    }
    
    @objc private func dismiss(_ pan: UIPanGestureRecognizer) {
        let point = pan.translation(in: pan.view)
        switch pan.state {
        case .began, .changed:
            if isInDismiss {
                calculateTranslate(point: point)
                return
            }
            //向左、上为负数，下、右为正数
            //如果y为正数大于40，并且X偏移值小于20，响应
            if point.y > 40 && fabs(point.x) < 20 {
                isInDismiss = true
                return
            }
        case .cancelled, .ended:
            if isInDismiss {
                isInDismiss = false
                if let `delegate` = delegate {
                    if !delegate.siglePictureView(self, didPanEnd: pan) {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.imageView.frame = self.originFrame ?? self.frame
                        })
                    }
                }
            }
        default:
            break
        }
    
    }
    
    private func calculateTranslate(point: CGPoint) {
        
        let center = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        let frame = originFrame ?? self.frame
        
        let absY = fabs(point.y) - 40
        var scale = absY * 0.65 / (0.25 * self.frame.size.height)
        scale = min(scale, 0.35)
        scale = 1.0 - scale
        scale = min(scale, 1.0)
        
        let width = scale * frame.size.width
        let height = scale * frame.size.height
        let x = center.x + point.x - width / 2.0
        let y = center.y + point.y - height / 2.0
        
        imageView.frame = CGRect(x: x, y: y, width: width, height: height)
    
    }

}

extension WKSiglePictureView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var frame = imageView.frame
        frame.origin.y = scrollView.frame.size.height > imageView.frame.size.height ? (scrollView.frame.size.height - imageView.frame.size.height) * 0.5 : 0
        frame.origin.x = scrollView.frame.size.width > imageView.frame.size.width ? (scrollView.frame.size.width - imageView.frame.size.width) * 0.5 : 0
        imageView.frame = frame
        scrollView.contentSize = CGSize(width: frame.size.width, height: frame.size.height)
    }
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.setZoomScale(1.0, animated: true)
    }
}

extension WKSiglePictureView: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer == panGesture
    }

    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        let point = pan.translation(in: pan.view)
        //当x大于y,并且不再dismiss中时，不响应响应拖动手势
        return !(fabs(point.y) < fabs(point.x) && !isInDismiss)
    }
    
}

