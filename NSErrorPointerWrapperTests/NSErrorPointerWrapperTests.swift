//  NSErrorPointerWrapperTests.swift
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

import XCTest
import NSErrorPointerWrapper

class NSErrorPointerWrapperTests: XCTestCase {

    func test_tryWithErrorPointer_Success_CallsOnSuccess() {
        let JSONData = properJSONData()

        tryWithErrorPointer { NSJSONSerialization.JSONObjectWithData(JSONData, options: nil, error: $0) }
            .onError { _ in XCTFail() }
            .onSuccess { _ in XCTAssert(true) }
    }

    func test_tryWithErrorPointer_FailureCreatesError_CallsOnErrorWithError() {
        let malformedJSONData = "{\"a\":}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!

        tryWithErrorPointer { NSJSONSerialization.JSONObjectWithData(malformedJSONData, options: nil, error: $0) }
            .onSuccess { _ in XCTFail() }
            .onError{ error in XCTAssertNotNil(error?) }
    }

    /**
        some of the APIs return Bool to indicate whether the operation was successful
        test example might be: NSManagedObjectContext().save($0) (returns false and doesn't set error)
    */

    func test_tryWithErrorPointer_FailureReturnsFalseErrorNil_CallsOnError() {
        let fake = Fake(result: false)

        tryWithErrorPointer { fake.potentiallyErroneousAction($0) }
            .onSuccess { _ in XCTFail() }
            .onError { _ in XCTAssert(true) }
    }

    func test_tryWithErrorPointer_SuccessReturnsTrue_CallsOnSuccessWithData() {
        let fake = Fake(result: true)

        tryWithErrorPointer { fake.potentiallyErroneousAction($0) }
            .onError { _ in XCTFail() }
            .onSuccess { data in XCTAssertTrue(data) }
    }

    /**
        some of the APIs to indicate error return nil value
    */
    func test_tryWithErrorPointer_FailureReturnsNil_CallsOnError() {
        let fake = Fake<AnyObject?>(result: nil)

        tryWithErrorPointer { fake.potentiallyErroneousAction($0) }
            .onSuccess { _ in XCTFail() }
            .onError{ _ in XCTAssertTrue(true) }
    }

    /**
        Note: use optional downcasting inside fun closure
        (*to avoid crash, since we can't tell whether the cast will be successful)
        tryWithError will call onError if the cast failed.
    */
    func test_tryWithErrorPointer_SuccessFailedCast_CallsOnError() {
        let JSONData = properJSONData()

        tryWithErrorPointer { NSJSONSerialization.JSONObjectWithData(JSONData, options: nil, error: $0) as? Int }
            .onSuccess { _ in XCTFail() }
            .onError { _ in XCTAssertTrue(true) }
    }

    func test_tryWithErrorPointer_SuccessSuccessfulCast_CallsOnSuccessWithData() {
        let JSONData = properJSONData()

        tryWithErrorPointer { NSJSONSerialization.JSONObjectWithData(JSONData, options: nil, error: $0) as? NSDictionary }
            .onError { _ in XCTFail() }
            .onSuccess { data in XCTAssertNotNil(data) }
    }

    func test_tryWithErrorPointerCastResulTo_SuccessFailedCast_CallsOnErrorWithFailedCastError() {
        let JSONData = properJSONData()

        tryWithErrorPointer(castResultTo: Int.self, { NSJSONSerialization.JSONObjectWithData(JSONData, options: nil, error: $0)} )
            .onSuccess { _ in XCTFail() }
            .onError { error in XCTAssertEqual(NSErrorPointerWrapperFailedDowncast, error!.code) }
    }

    func test_tryWithErrorPointerCastResultTo_SuccessSuccessfulCast_CallsOnSuccessWithData() {
        let JSONData = properJSONData()

        tryWithErrorPointer(castResultTo: NSDictionary.self) { NSJSONSerialization.JSONObjectWithData(JSONData, options: nil, error: $0) }
            .onError{ _ in XCTFail() }
            .onSuccess{ XCTAssertNotNil($0); return }
    }
}

// MARK: -

private struct Fake<T> {
    let result: T

    func potentiallyErroneousAction(error: NSErrorPointer) -> T {
        return result
    }
}

private func properJSONData() -> NSData {
    return "{\"a\":\"b\"}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
}
