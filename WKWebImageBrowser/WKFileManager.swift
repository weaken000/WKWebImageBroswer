//
//  WKFileManager.swift
//  WKWebPictureBrowserExample
//
//  Created by yzl on 18/2/12.
//  Copyright © 2018年 lwk. All rights reserved.
//

import UIKit

public class WKFileManager {
    
    private static let manager = WKFileManager()

    private let directoryName = "com.wk.picturebroswer"
    
    private lazy var fileManager: FileManager = {
        return FileManager.default
    }()
    
    public var wkCachePath: String {
        get {
            let caches = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
            if !fileManager.fileExists(atPath: caches.appendingPathComponent(directoryName)) {
                do {
                    try fileManager.createDirectory(atPath: caches.appendingPathComponent(directoryName), withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("创建文档失败")
                }
            }
            return caches.appendingPathComponent(directoryName)
        }
    }
    
    public var cacheSize: UInt64 {
        
        var isDirectory: ObjCBool = true
        let isExists = fileManager.fileExists(atPath: wkCachePath, isDirectory: &isDirectory)
        var size: UInt64 = 0
        if isExists {
            do {
                let attr = try fileManager.attributesOfItem(atPath: wkCachePath)
                size = attr[FileAttributeKey.size] as! UInt64
            } catch  {
                
            }
        }
        
        return size
    }
    
    public static var `default`: WKFileManager {
        return manager
    }
    //取出对应文件
    public func fileExists(fileName: String) -> (Bool, Data?) {
        var files = [String]()
        do {
            files = try fileManager.contentsOfDirectory(atPath: wkCachePath)
        } catch {
            return (false, nil)
        }
        
        let path = (WKFileManager.default.wkCachePath as NSString)
        for item in files {
            if fileName == item {
                let data = try? Data(contentsOf: URL(fileURLWithPath: (path.appendingPathComponent(fileName) as String)))
                guard let imageData = data else {
                    return (false, nil)
                }
                return (true, imageData)
            }
        }
        
        return (false, nil)
    }
    ///保存文件
    @discardableResult
    public func save(_ data: Data?, from url: URL?, to fileName: String) -> String? {
        let path = (wkCachePath as NSString).appendingPathComponent(fileName) as String
        do {
            if fileManager.fileExists(atPath: path) {
                try fileManager.removeItem(atPath: path)
            }
            if let url = url {
                try fileManager.moveItem(at: url, to: URL(fileURLWithPath: path))
            }
            else {
                guard let data = data else {
                    return nil
                }
                try data.write(to: URL(fileURLWithPath: path))
            }
        }
        catch  {
            return nil
        }
        
        return path
    }
    
    public func clearCache() {
        try? fileManager.removeItem(atPath: wkCachePath)
    }
    
}
