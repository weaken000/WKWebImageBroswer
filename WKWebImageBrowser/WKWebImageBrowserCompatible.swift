//
//  WKWebImageBrowserCompatible.swift
//  WKWebPictureBrowserExample
//
//  Created by yzl on 18/2/12.
//  Copyright © 2018年 lwk. All rights reserved.
//

import UIKit

public class WKWebImageBrowserCompatible<Base> {
    public let base : Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol WKWebImageCompatible {
    associatedtype Compatible
    var wk: Compatible { get }
}

public extension WKWebImageCompatible {
    var wk: WKWebImageBrowserCompatible<Self> {
        return WKWebImageBrowserCompatible(self)
    }
}

extension UIImageView: WKWebImageCompatible {  }

extension UIButton: WKWebImageCompatible {  }
