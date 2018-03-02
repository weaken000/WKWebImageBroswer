# WKWebPictureBroswer
图片浏览器

### 功能介绍
图片的异步下载，本地缓存
imageView的缓存复用

### CocoaPod
    pod 'WKWebImageBrowser', '~> 0.0.1'
### API

图片下载

    let imageView = UIImageView()
    imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
    view.addSubview(imageView)
    imageView.wk.setImage(url: URL(string: "url")!, placeHolder: nil, progress: { (progress) in  }) { (image, error) in }

图片浏览器

    let imageView = UIImageView()
    imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
    view.addSubview(imageView)
    
    let vc = WKPictureBroswerViewController(urls: ["", ""], index: 0, fromView: imageView)
    self.present(vc, animated: true, completion: nil)
    
    let vc = WKPictureBroswerViewController(urls: ["", ""], index: 0, fromView: imageView)
    self.navigationController?.delegate = vc
    self.navigationController?.pushViewController(vc, animated: true)
    
### 效果展示

![image](https://github.com/weaken000/WKWebImageBroswer/blob/master/WKWebImageBrowserExample/WKWebImageBrowserExample/example.gif)
