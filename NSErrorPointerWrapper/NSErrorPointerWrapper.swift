//
//  NSErrorPointerWrapper.swift
//
//  Copyright (c) 2014 Witold Skibniewski
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation

public let NSErrorPointerDomain = "Error by reference"
public let NSErrorPointerWrapperFailedDowncast = -1

/**
    sample usage: tryWithErrorPointer(castResultTo: NSDictionary.self) {  NSJSONSerialization.JSONObjectWithData(JSONData, options: nil, error: $0) }

    If casting fails `onError` handler is called with `NSError` (code: `NSErrorPointerWrapperFailedDowncast`).

    :castResultTo: Type that the result should be downcasted to.
*/
public func tryWithErrorPointer<T>(castResultTo type: T.Type, fun: NSErrorPointer -> AnyObject?) -> ErrorPointerResult<T> {
    var (result: AnyObject?, error) = privateTryWithErrorPointer(fun)
        var downcastedResult: T?
        switch result {
        case .None:
            false
        case .Some(let data as T):
            downcastedResult = data
        case .Some(_):
            error = downcastError()
        }

    return ErrorPointerResult(data: downcastedResult, error: error)
}

public func tryWithErrorPointer(fun: NSErrorPointer -> Bool) -> ErrorPointerResult<Bool> {
    var (result, error) = privateTryWithErrorPointer(fun)
    return ErrorPointerResult(data: result!, error: error)
}

public func tryWithErrorPointer<T>(fun: NSErrorPointer -> T?) -> ErrorPointerResult<T?> {
    let (result, error) = privateTryWithErrorPointer(fun)
    return ErrorPointerResult(data: result?, error: error)
}

private func privateTryWithErrorPointer<T>(fun: NSErrorPointer -> T?) -> (result: T?, error: NSError?) {
    var possibleError: NSError?
    let result: T? = fun(&possibleError)
    return (result: result, error: possibleError)
}

private func downcastError() -> NSError {
    return NSError(domain: NSErrorPointerDomain, code: NSErrorPointerWrapperFailedDowncast, userInfo: nil)
}

public struct ErrorPointerResult<T> {
    private let data: T?
    private let error: NSError?
    private var success:Bool {
        switch data? {
        case .None:
            return false
        case .Some(let success as Bool):
            return success
        case .Some(_):
            return true
        }
    }

    public func onError(fun: NSError? -> ()) -> ErrorPointerResult {
        if !success {
            fun(error)
        }
        return self
    }

    public func onSuccess(fun: T -> ()) -> ErrorPointerResult {
        if success {
            fun(data!)
        }
        return self
    }
}
