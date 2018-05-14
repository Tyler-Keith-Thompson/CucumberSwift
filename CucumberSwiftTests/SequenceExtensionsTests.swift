//
//  SequenceExtensionsTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 5/13/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
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
}
