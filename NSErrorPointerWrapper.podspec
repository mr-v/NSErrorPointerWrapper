# coding: utf-8

Pod::Spec.new do |s|
  s.name         = "NSErrorPointerWrapper"
  s.version      = "0.1.1"
  s.summary      = "Simplified error handling for Cocoa Touch APIs in Swift"
  s.description  = <<-DESC
Swift wrapper functions that simplify handling of methods that take in `NSErrorPoint`. Some of the benefits:

- no more declaring that pesky `NSError` variable to pass by reference (use `$0` shorthand argument name in closure passed to wrapper)
- handlers chaining for success and failure
- streamlined downcasting handling (needed because often the result of those methods is `AnyObject?` instance)
                   DESC
  s.homepage     = "https://github.com/mr-v/NSErrorPointerWrapper"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "mr-v" => "witold.skibniewski@gmail.com" }
  s.platform = :ios, "8.0"
#  s.ios.deployment_target = "7.0"
#  s.osx.deployment_target = "10.9"
  s.source       = { :git => "https://github.com/mr-v/NSErrorPointerWrapper.git", :tag => "#{s.version}" }
  s.source_files  = "NSErrorPointerWrapper"
  s.requires_arc = true
end
