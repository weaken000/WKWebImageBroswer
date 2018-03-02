//
//  ViewController.swift
//  WKWebImageBrowserExample
//
//  Created by yzl on 18/2/12.
//  Copyright © 2018年 lwk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var presentImageView: UIImageView!
    var pushImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "WKWebImageBrowser"
        //清除缓存
        print(WKFileManager.default.cacheSize)
        
        WKFileManager.default.clearCache()
        
        setupSubviews()
    }
    
    func setupSubviews() {
        presentImageView = UIImageView()
        presentImageView.isUserInteractionEnabled = true
        presentImageView.wk.setImage(url: URL(string: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1517822982226&di=7b8c945969eb36e45b1ec14ad0f7ea53&imgtype=0&src=http%3A%2F%2Fol01.tgbusdata.cn%2Fv2%2Fthumb%2Fjpg%2FRTFCMyw1ODAsMTAwLDQsMywxLC0xLDAscms1MCwxOTIuMTY4LjguNjc%3D%2Fu%2Fiphone.tgbus.com%2FUploadFiles%2F201712%2F2017121813381508.jpg"), placeHolder: UIImage(named: ""), progress: { (progress) in
            
        }) { (image, error) in
            
        }
        let width = view.frame.size.width
        let height = view.frame.size.height
        presentImageView.frame = CGRect(x: (width - 200.0) / 2.0, y: (height / 2.0 - 200.0 - 50.0), width: 200, height: 200)
        presentImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap_presentImageView)))
        view.addSubview(presentImageView)
        
        pushImageView = UIImageView()
        pushImageView.isUserInteractionEnabled = true
        pushImageView.wk.setImage(url: URL(string: "http://img.zcool.cn/community/0159fa5944bcd3a8012193a34b762d.jpg@2o.jpg"), placeHolder: UIImage(named: ""), progress: { (progress) in
            
        }) { (image, error) in
            
        }
        pushImageView.frame = CGRect(x: (width - 200.0) / 2.0, y: (height / 2.0 + 50.0), width: 200, height: 200)
        pushImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tap_pushImageView)))
        view.addSubview(pushImageView)
    }
    
    func tap_presentImageView() {
        if let vc = WKPictureBrowserViewController(urls: ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1517822982226&di=7b8c945969eb36e45b1ec14ad0f7ea53&imgtype=0&src=http%3A%2F%2Fol01.tgbusdata.cn%2Fv2%2Fthumb%2Fjpg%2FRTFCMyw1ODAsMTAwLDQsMywxLC0xLDAscms1MCwxOTIuMTY4LjguNjc%3D%2Fu%2Fiphone.tgbus.com%2FUploadFiles%2F201712%2F2017121813381508.jpg",
                                                          "http://img.zcool.cn/community/0159fa5944bcd3a8012193a34b762d.jpg@2o.jpg",
                                                          "http://a3.topitme.com/2/67/74/11489000958d174672o.jpg",
                                                          "http://img.zcool.cn/community/010f2a5944bc9ba8012193a3190f53.jpg@2o.jpg",
                                                          "http://a3.topitme.com/a/0b/42/1161343925b5a420bao.jpg",
                                                          "http://img4.duitang.com/uploads/item/201210/24/20121024114604_Tzzm4.jpeg",
                                                          "http://d.hiphotos.baidu.com/zhidao/pic/item/9213b07eca806538ef7a124495dda144ac3482d1.jpg",
                                                          "http://pic38.nipic.com/20140214/11962352_153850532179_2.jpg",
                                                          "http://h.hiphotos.baidu.com/zhidao/pic/item/8718367adab44aed51870429b21c8701a08bfb36.jpg",
                                                          "http://imgsrc.baidu.com/image/c0%3Dpixel_huitu%2C0%2C0%2C294%2C40/sign=526f7de67dc6a7efad2ba0669482ca3d/6d81800a19d8bc3e044bdef3898ba61ea8d3454c.jpg",
                                                          "http://a3.topitme.com/3/19/e7/1136972600c1be7193o.jpg"], index: 3, fromView: presentImageView) {
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    func tap_pushImageView() {
        if let vc = WKPictureBrowserViewController(urls: ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1517822982226&di=7b8c945969eb36e45b1ec14ad0f7ea53&imgtype=0&src=http%3A%2F%2Fol01.tgbusdata.cn%2Fv2%2Fthumb%2Fjpg%2FRTFCMyw1ODAsMTAwLDQsMywxLC0xLDAscms1MCwxOTIuMTY4LjguNjc%3D%2Fu%2Fiphone.tgbus.com%2FUploadFiles%2F201712%2F2017121813381508.jpg",
                                                          "http://img.zcool.cn/community/0159fa5944bcd3a8012193a34b762d.jpg@2o.jpg",
                                                          "http://a3.topitme.com/2/67/74/11489000958d174672o.jpg",
                                                          "http://img.zcool.cn/community/010f2a5944bc9ba8012193a3190f53.jpg@2o.jpg",
                                                          "http://a3.topitme.com/a/0b/42/1161343925b5a420bao.jpg",
                                                          "http://img4.duitang.com/uploads/item/201210/24/20121024114604_Tzzm4.jpeg",
                                                          "http://d.hiphotos.baidu.com/zhidao/pic/item/9213b07eca806538ef7a124495dda144ac3482d1.jpg",
                                                          "http://pic38.nipic.com/20140214/11962352_153850532179_2.jpg",
                                                          "http://h.hiphotos.baidu.com/zhidao/pic/item/8718367adab44aed51870429b21c8701a08bfb36.jpg",
                                                          "http://imgsrc.baidu.com/image/c0%3Dpixel_huitu%2C0%2C0%2C294%2C40/sign=526f7de67dc6a7efad2ba0669482ca3d/6d81800a19d8bc3e044bdef3898ba61ea8d3454c.jpg",
                                                          "http://a3.topitme.com/3/19/e7/1136972600c1be7193o.jpg"], index: 0, fromView: pushImageView) {
            navigationController?.delegate = vc
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }


}

