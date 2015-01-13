# NSErrorPointerWrapper
Wrapper for handling iOS SDK APIs that take in error by reference.

Some of the benefits:

- Simplified handling of methods that take in `NSErrorPoint`.
- No more declaring that pesky `NSError` variable to pass by reference (use `$0` shorthand argument name in closure passed to the wrapper).
- Chaining handlers for success and failure.
- Streamlined downcasting handling (needed because often the result of those methods is `AnyObject?` instance).

# Usage
```swift
tryWithErrorPointer { NSJSONSerialization.JSONObjectWithData(data, options: nil, error: $0) }
                .onError { error in /* handle error */ }
                .onSuccess { result in /* handle success */ } }
```

With casting:

```swift
tryWithErrorPointer(castResultTo: NSDictionary.self) { NSJSONSerialization.JSONObjectWithData(data, options: nil, error: $0) }
                .onError { error in /* handle error */ }
                .onSuccess { result in /* handle success */ } }
```

For more details check [tests](https://github.com/mr-v/NSErrorPointerWrapper/blob/master/NSErrorPointerWrapperTests/NSErrorPointerWrapperTests.swift) and those resources:

- [NSErrorPointerWrapper: Simplified handling of Cocoa Touch API errors in Swift](http://mr-v.github.io/nserrorpointerwrapper-simplified-handling-of-cocoa-touch-api-errors-in-swift/),
- sample app: [swift-objc.io-issue-10-core-data-network-application](https://github.com/mr-v/swift-objc.io-issue-10-core-data-network-application).

# Installation with CocoaPods

- You need to use CocoaPods version that supports Frameworks: at least 0.36.0. Currently it's a beta feature, to install it update CocoaPods: `gem install cocoapods --prerelease`.
- In your `Podfile` setup `NSErrorPointerWrapper` pointing to its repo and tag version (need to do it this way, because currently pushing to Spec repo fails with code signing error).
```ruby
pod 'NSErrorPointerWrapper', :git => "https://github.com/mr-v/NSErrorPointerWrapper.git", :tag => "0.1.0"
```
