//
//  SequenceExtensionsTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 5/13/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

class SequenceExtensionsTests : XCTestCase {
    func testSafeIndiceAccessor() {
        let arr = [1, 2, 3]
        XCTAssertEqual(arr[safe: 0], 1)
        XCTAssertEqual(arr[safe: 1], 2)
        XCTAssertEqual(arr[safe: 2], 3)
        XCTAssertEqual(arr[safe: 3], nil)
    }
    
    func testCanReturnUniqueValues() {
        XCTAssertEqual([1, 1, 2, 3].uniqueElements, [1, 2, 3])
    }
    
    func testCanRemoveDuplicateValues() {
        var arr = [1, 1, 2, 3]
        arr.removeDuplicates()
        XCTAssertEqual(arr, [1, 2, 3])
    }
    
    func testAppendingSingleElementDoesNotMutate() {
        let arr = [1, 2, 3]
        XCTAssertEqual(arr.appending(1).count, 4)
        XCTAssertEqual(arr.appending(15).last, 15)
    }

    func testAppendingContentsOfArrayDoesNotMutate() {
        let arr = [1, 2, 3]
        XCTAssertEqual(arr.appending(contentsOf: [1]).count, 4)
        XCTAssertEqual(arr.appending(contentsOf: [15]).last, 15)
    }
}
