Pod::Spec.new do |s|
  s.name         = "WKWebImageBrowser"
  s.version      = "0.0.1"
  s.summary      = "A full screen WebImageBrowser."
  s.homepage     = "https://github.com/weaken000/WKWebImageBroswer"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "weaken" => "845188093@qq.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/weaken000/WKWebImageBroswer.git", :tag => s.version }
  s.requires_arc = true
  s.source_files = "WKWebImageBrowser/*.swift"
  s.resource     = 'WKWebImageBrowser/*.png'
  s.ios.deployment_target = "8.0"
  s.frameworks = 'UIKit', 'Foundation'
  s.swift_version = '4.0'
end
