//
//  StringExtensionsTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 4/8/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

class StringExtensionsTests : XCTestCase {
    func testMatchesReturnsCorrectMatchesForRegex() {
        let matches = "This is a test".matches(for: "^(.*?) is a test$")
        XCTAssertEqual(matches.count, 2)
        XCTAssertEqual(matches.first, "This is a test")
        XCTAssertEqual(matches.last, "This")
    }
    
    func testMatchesReturnsAnEmptyArrayForInvalidRegex() {
        let matches = "This is a test".matches(for: "^(.*? is a test$")
        XCTAssertEqual(matches.count, 0)
    }
    
    func testMatchesReturnsAnEmptyArrayForNonMatchingRegex() {
        let matches = "This is a test".matches(for: "^xc7qqv....$")
        XCTAssertEqual(matches.count, 0)
    }
}
