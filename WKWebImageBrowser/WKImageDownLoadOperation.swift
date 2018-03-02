//
//  WKImageDownLoadOperation.swift
//  WashHelper
//
//  Created by yzl on 18/2/1.
//  Copyright © 2018年 lwk. All rights reserved.
//

import UIKit

class WKImageDownLoadOperation: Operation {
    
    internal var session: URLSession?
    internal var task: URLSessionDownloadTask?
    internal let url: URL
    
    fileprivate var progress: ((Double)->Void)?
    fileprivate var completion: ((UIImage?, Error?)->Void)?
    
    private var _executing : Bool = false
    private var _finished  : Bool = false
    fileprivate var hasComplete: Bool = false
    
    init(url: URL,
         progress: ((Double)->Void)?,
         completion: ((UIImage?, Error?)->Void)?) {
        
        self.url = url
        self.progress = progress
        self.completion = completion
        
        super.init()
    }
    
    //Methods
    override func start() {
        
        if isCancelled {
            isFinished = true
            return
        }
        
        isExecuting = true
     
        let fileName = url.absoluteString.md5
        var resumeData: Data?
        //获取图片文件
        let (isExists, imageData) = WKFileManager.default.fileExists(fileName: fileName)
        
        if let imageData = imageData, isExists {
            if let image = UIImage(data: imageData) {
                
                self.isFinished = true
                self.isExecuting = false
                DispatchQueue.main.async {
                    self.progress?(1.0)
                    if !self.hasComplete {
                        self.hasComplete = true
                        self.completion?(image, nil)
                    }
                }
                return
            }
        }
        
        resumeData = imageData
        
        session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        if let data = resumeData {
            task = session?.downloadTask(withResumeData: data)
        }
        else {
            task = session?.downloadTask(with: url)
        }
        task?.resume()
    }
    
    override func cancel() {
        if isFinished {
            super.cancel()
            return
        }
        
        isExecuting = false
        task?.cancel(byProducingResumeData: { [weak self] (data) in
            guard let `self` = self, let imageData = data else {
                return
            }
            WKFileManager.default.save(imageData, from: nil, to: self.url.absoluteString.md5)
        })
        super.cancel()
        
    }
    
    override var isConcurrent: Bool {
        get {
            return true
        }
    }
    override var isExecuting: Bool {
        get { return _executing }
        set {
            self.willChangeValue(forKey: "isExecuting")
            _executing = newValue
            self.didChangeValue(forKey: "isExecuting")
        }
    }
    override var isFinished: Bool {
        get { return _finished }
        set {
            self.willChangeValue(forKey: "isFinished")
            _finished = newValue
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
}

extension WKImageDownLoadOperation: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        session.finishTasksAndInvalidate()
        
        isFinished = true
        isExecuting = false
        
        if !hasComplete {
            hasComplete = true
            if let path = WKFileManager.default.save(nil, from: location, to: self.url.absoluteString.md5) {
                let image = UIImage(contentsOfFile: path)
                completion?(image, nil)
            }
        }
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percent = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            progress?(percent)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        isFinished = true
        isExecuting = false
        session.finishTasksAndInvalidate()
        
        guard let `error` = error else {
            return
        }
        
        if !hasComplete {
            hasComplete = true
            completion?(nil, error)
        }
        
    }
    
}
