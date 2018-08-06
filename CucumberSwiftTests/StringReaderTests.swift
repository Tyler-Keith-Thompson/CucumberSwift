//
//  StringReaderTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 8/5/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

class StringReaderTests: XCTestCase {
    func testStringReaderDoesNotOverFlowAtStartOrEndOfString() {
        let sr = StringReader("test")
        sr.readUntil { _ in false }
        sr.readBehindUntil { _ in false }
    }
    
    func testStringReaderLooksAheadWithoutMovingTheHeadOfTheReader() {
        let sr = StringReader("test")
        let str = sr.lookAheadUntil { $0 == "e" }
        XCTAssertEqual(str, "t")
        XCTAssertEqual(sr.index, sr.input.startIndex)
    }
    
    func testStringReaderLooksBehindWithoutMovingTheHeadOfTheReader() {
        let sr = StringReader("test")
        sr.readUntil { _ in false }
        let str = sr.lookBehindUntil { $0 == "e" }
        XCTAssertEqual(str, "st")
        XCTAssertEqual(sr.index, sr.input.endIndex)
    }
}
