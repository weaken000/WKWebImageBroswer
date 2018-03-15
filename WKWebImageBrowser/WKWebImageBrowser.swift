//
//  WKPictureBroswer.swift
//  WashHelper
//
//  Created by yzl on 18/1/23.
//  Copyright © 2018年 lwk. All rights reserved.
//

import UIKit

class WKImageData {
    var url: String = ""
    var imageData: Data?
    var image: UIImage?
    var index: Int = 0
    
    init(url: String, imageData: Data?, image: UIImage?, index: Int) {
        self.url = url
        self.imageData = imageData
        self.image = image
        self.index = index
    }
    
}

class WKWebImageBrowser: UIView {
    
    //MARK: Property
    internal let minCacheNumber = 4
    
    internal var currentPictureView: WKSiglePictureView?
    
    internal var handlerGesture: ((UIPanGestureRecognizer)->Bool)?
    
    internal var handlerDismissAction: (()->Void)?
    
    private var siglePictureViewPool = [WKSiglePictureView]()
    
    private var siglePictureViewArray = [WKSiglePictureView]()
    
    private let titleLabel: UILabel
    
    private let broswerScroll: UIScrollView
    
    private let dismissButton: UIButton
    
    private var imageDataList = [WKImageData]()
    
    private let currentIndex: Int
    
    private var lastIndex = 0
    
    private let WKScrollContentOffset = "contentOffset"

    //MARK: LifeCircle
    init(frame: CGRect, urls: [String], currentIndex: Int) {
        
        titleLabel = UILabel()
        broswerScroll = UIScrollView()
        dismissButton = UIButton()
        for (index, url) in urls.enumerated() {
            let imageData = WKImageData(url: url, imageData: nil, image: nil, index: index)
            imageDataList.append(imageData)
        }
        self.currentIndex = currentIndex
        self.lastIndex = currentIndex
        
        super.init(frame: frame)
    
        backgroundColor = UIColor.clear
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Override
    override func layoutSubviews() {
        titleLabel.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 44)
        dismissButton.frame = CGRect(x: 15, y: 8, width: 28, height: 28)
        broswerScroll.frame = CGRect(x: 0, y: 44, width: frame.size.width, height: frame.size.height-44)
        broswerScroll.contentSize = CGSize(width: CGFloat(imageDataList.count) * frame.size.width, height: 0)
        super.layoutSubviews()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == WKScrollContentOffset {
            findPictureView(change: change)
        }
    }
    
    //MARK: Methods
    private func setup() {
        
        
        
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        addSubview(titleLabel)
        
        dismissButton.addTarget(self, action: #selector(self.clickDismissButton(_:)), for: .touchUpInside)
        dismissButton.setImage(UIImage(named: "arrow_left_white.png"), for: .normal)
        addSubview(dismissButton)
        
        broswerScroll.showsHorizontalScrollIndicator = false
        broswerScroll.contentSize = CGSize(width: CGFloat(imageDataList.count) * self.frame.size.width, height: 0)
        broswerScroll.contentOffset = CGPoint(x: CGFloat(currentIndex) * self.frame.size.width, y: 0)
        broswerScroll.isPagingEnabled = true
        addSubview(broswerScroll)
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: 44)
        dismissButton.frame = CGRect(x: 15, y: 8, width: 28, height: 28)
        broswerScroll.frame = CGRect(x: 0, y: 44, width: self.frame.size.width, height: self.frame.size.height-44.0)
        titleLabel.text = "\(currentIndex+1)/\(imageDataList.count)"
        
        //初始化第一个
        let firstPictureView = WKSiglePictureView(frame: CGRect(x: CGFloat(currentIndex) * broswerScroll.frame.size.width, y: 0, width: broswerScroll.frame.size.width, height: broswerScroll.frame.size.height))
        firstPictureView.delegate = self
        firstPictureView.indexX = currentIndex
        firstPictureView.imageData = imageDataList[currentIndex]
        broswerScroll.addSubview(firstPictureView)
        siglePictureViewArray.append(firstPictureView)
        currentPictureView = firstPictureView
        
        broswerScroll.addObserver(self, forKeyPath: WKScrollContentOffset, options: [.old, .new], context: nil)
    }
    
    private func findPictureView(change: [NSKeyValueChangeKey : Any]?) {
        
        guard let `change` = change else {
            return
        }
        
        guard let oldOffset = change[.oldKey] as? CGPoint, let newOffset = change[.newKey] as? CGPoint else {
            return
        }
        
        //创建缓存
        installCache(oldOffset: oldOffset, newOffset: newOffset)
        
        let offsetIndex = newOffset.x / self.frame.size.width
        let index = Int(offsetIndex)
        
        if oldOffset.x < newOffset.x {//向右
            //1.查找是否当前位置是否存在图片视图

            //当整除时，下一个页面就是当前页面
            var nextIndex: Int
            if offsetIndex == CGFloat(index) {//整除,说明视图完全展现
                nextIndex = index
            }
            else {
                nextIndex = index + 1
            }
            
            if nextIndex >= imageDataList.count {
                return
            }
            
            var pictureTemp: WKSiglePictureView?
            
            for pictureView in siglePictureViewArray {
                if pictureView.indexX == nextIndex {
                    pictureTemp = pictureView
                    break
                }
            }
            //2.已经找到当前位置存在的图片视图，直接设置模型
            if pictureTemp == nil {//3.当缓存数量小于最小数量时，直接生成一个新的图片视图
                if siglePictureViewArray.count < minCacheNumber {
                    pictureTemp = setupPicture()
                    broswerScroll.addSubview(pictureTemp!)
                    siglePictureViewArray.append(pictureTemp!)
                }
                else {//4.没有在指定位置找到视图，在视图缓存池中查看是否存在图片视图，选取一个
                    pictureTemp = siglePictureViewPool.first
                }
            }
            //设置位置
            pictureTemp?.frame = CGRect(x: CGFloat(nextIndex)*broswerScroll.frame.size.width, y: 0, width: broswerScroll.frame.size.width, height: broswerScroll.frame.size.height)
            //设置索引
            pictureTemp?.indexX = nextIndex

        
            //当下一个视图还未完全展现
            if offsetIndex != CGFloat(index) {
                if imageDataList[nextIndex].image != nil {//图片已经完成，则直接设置
                    pictureTemp?.imageData = imageDataList[nextIndex]
                }
                else {//未完成，则清空视图图片
                    pictureTemp?.imageView.image = nil
                }
            }
            
            //下一个视图已经完全展示，下载图片
            if offsetIndex == CGFloat(index) {
                pictureTemp?.imageData = imageDataList[nextIndex]
                titleLabel.text = "\(nextIndex+1)/\(imageDataList.count)"
                currentPictureView = pictureTemp
            }
        

            //移出缓存池
            if let i = siglePictureViewPool.index(of: pictureTemp!) {
                siglePictureViewPool.remove(at: i)
            }
            
        }
        else if oldOffset.x > newOffset.x {//向左
            
            //1.查找是否当前位置是否存在图片视图
            let nextIndex = index

            if offsetIndex < 0 {
                return
            }
            var pictureTemp: WKSiglePictureView?
            for pictureView in siglePictureViewArray {
                if pictureView.indexX == nextIndex {
                    pictureTemp = pictureView
                    break
                }
            }
            //2.已经找到当前位置存在的图片视图，直接设置模型
            if pictureTemp == nil {//3.当缓存数量小于最小数量时，直接生成一个新的图片视图
                if siglePictureViewArray.count < minCacheNumber {
                    pictureTemp = setupPicture()
                    broswerScroll.addSubview(pictureTemp!)
                    siglePictureViewArray.append(pictureTemp!)
                }
                else {//4.没有在指定位置找到视图，在视图缓存池中查看是否存在图片视图，选取一个
                    pictureTemp = siglePictureViewPool.first
                }
            }
            //设置位置
            pictureTemp?.frame = CGRect(x: CGFloat(nextIndex)*broswerScroll.frame.size.width,
                                        y: 0,
                                        width: broswerScroll.frame.size.width,
                                        height: broswerScroll.frame.size.height)
            //设置索引
            pictureTemp?.indexX = nextIndex

            //当下一个视图还未完全展现
            if offsetIndex != CGFloat(index) {
                if imageDataList[nextIndex].image != nil {//图片已经完成，则直接设置
                    pictureTemp?.imageData = imageDataList[nextIndex]
                }
                else {//未完成，则清空视图图片
                    pictureTemp?.imageView.image = nil
                }
            }
            //下一个视图已经完全展示，下载图片
            if offsetIndex == CGFloat(index) {
                pictureTemp?.imageData = imageDataList[nextIndex]
                titleLabel.text = "\(nextIndex+1)/\(imageDataList.count)"
                currentPictureView = pictureTemp
            }
            
            //移出缓存池
            if let i = siglePictureViewPool.index(of: pictureTemp!) {
                siglePictureViewPool.remove(at: i)
            }
            
        }
    }
    
    private func setupPicture() -> WKSiglePictureView {
        let picture = WKSiglePictureView(frame: CGRect(x: 0, y: 0, width: broswerScroll.frame.size.width, height: broswerScroll.frame.size.height))
        picture.delegate = self
        return picture
    }
    
    private func installCache(oldOffset: CGPoint, newOffset: CGPoint) {
        
        let toRight = oldOffset.x < newOffset.x
        
        if toRight {
            if newOffset.x >= CGFloat(lastIndex+1) * self.frame.size.width {//缓存左边
                for pictureView in siglePictureViewArray {
                    if pictureView.indexX == (lastIndex) && !siglePictureViewPool.contains(pictureView) {
                        siglePictureViewPool.append(pictureView)
                        break
                    }
                }
                lastIndex += 1
            }
        }
        else {
            if newOffset.x <= CGFloat(lastIndex-1) * self.frame.size.width {//缓存右边
                for pictureView in siglePictureViewArray {
                    if pictureView.indexX == lastIndex && !siglePictureViewPool.contains(pictureView) {
                        siglePictureViewPool.append(pictureView)
                        break
                    }
                }
                lastIndex -= 1
            }
        }
        
    }
    
    @objc private func clickDismissButton(_ sender: UIButton) {
        if let handler = handlerDismissAction {
            handler()
        }
    }
    
    deinit {
        broswerScroll.removeObserver(self, forKeyPath: WKScrollContentOffset)
    }
    
}

extension WKWebImageBrowser: WKSiglePictureViewDelegate {
    
    func siglePictureView(_ pictureView: WKSiglePictureView, didPanEnd gesture: UIPanGestureRecognizer) -> Bool {
        currentPictureView = pictureView
        if let handler = handlerGesture {
            return handler(gesture)
        }
        return false
    }
    
}

