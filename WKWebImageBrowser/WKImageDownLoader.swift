//
//  WKImageDownLoader.swift
//  WashHelper
//
//  Created by yzl on 18/2/1.
//  Copyright © 2018年 lwk. All rights reserved.
//

import UIKit
import Foundation

fileprivate var ImageViewURL = 0
fileprivate var ButtonURL = 0

class WKImageDownLoader {

    private static let manager = WKImageDownLoader()
    private var operations = [WKImageDownLoadOperation]()
    private let requestQueue: OperationQueue = OperationQueue()
    private var lock = NSLock()
    
    public static var share: WKImageDownLoader {
        return manager
    }

    public func downLoadImage(_ url: URL,
                              progress: ((Double)->Void)?,
                              completion: ((UIImage?, Error?)->Void)?)
    {
        
        lock.lock()

        var operation: WKImageDownLoadOperation!
        
        let loadCompletion = { [weak self, weak operation] (image: UIImage?, error: Error?) in
            if let handler = completion {
                handler(image, error)
            }
            if let `self` = self, let op = operation {
                if let index = self.operations.index(of: op) {
                    self.operations.remove(at: index)
                    op.cancel()
                }
            }
        }
        
        operation = WKImageDownLoadOperation(url: url, progress: progress, completion: loadCompletion)
        requestQueue.addOperation(operation)
        operations.append(operation)
        
        lock.unlock()
    }
    
    public func cancelAllOperation() {
        requestQueue.cancelAllOperations()
        operations.removeAll()
    }
    
    public func cancel(_ url: URL) {
        let tmp = operations
        for (index, op) in tmp.enumerated() {
            if op.url.absoluteString == url.absoluteString {
                op.cancel()
                operations.remove(at: index)
                break
            }
        }
    }

}

extension UIImageView {
    public var url: URL? {
        set {
            objc_setAssociatedObject(self, &ImageViewURL, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &ImageViewURL) as? URL
        }
    }
}

extension WKWebImageBrowserCompatible where Base: UIImageView {
    
    public func setImage(url: URL?,
                         placeHolder: UIImage? = nil,
                         progress: ((Double)->Void)? = nil,
                         completion: ((UIImage?, Error?)->Void)? = nil)
    {
        
        guard let url = url else {
            return
        }
        
        if let oldURL = base.url {
            if oldURL.absoluteString != url.absoluteString {
                WKImageDownLoader.share.cancel(oldURL)
                base.url = url
            }
            else {
                return
            }
        }
        else {
            base.url = url
        }
        
        if placeHolder != nil {
            base.image = placeHolder
        }
        
        WKImageDownLoader.share
            .downLoadImage(url, progress: { (percent) in
                progress?(percent)
            })
            { (image, error) in
                self.base.image = image
                completion?(image, error)
            }
        
    }
    
}

extension UIButton {
    public var url: URL? {
        set {
            objc_setAssociatedObject(self, &ButtonURL, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &ButtonURL) as? URL
        }
    }
}

extension WKWebImageBrowserCompatible where Base: UIButton {
    
    public func setImage(url: URL?,
                         for state: UIControlState,
                         placeHolder: UIImage? = nil,
                         progress: ((Double)->Void)? = nil,
                         completion: ((UIImage?, Error?)->Void)? = nil)
    {
        guard let url = url else {
            return
        }
        
        if let oldURL = base.url {
            if oldURL.absoluteString != url.absoluteString {
                WKImageDownLoader.share.cancel(oldURL)
                base.url = url
            }
            else {
                return
            }
        }
        else {
            base.url = url
        }
        
        if placeHolder != nil {
            base.setImage(placeHolder, for: state)
        }
        
        WKImageDownLoader.share.downLoadImage(url, progress: { (percent) in
            progress?(percent)
        }) { (image, error) in
                self.base.setImage(image, for: state)
                completion?(image, error)
        }
        
    }
    
}



