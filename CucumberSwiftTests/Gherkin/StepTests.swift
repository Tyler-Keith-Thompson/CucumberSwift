//
//  StepTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 4/8/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}

class StepTests: XCTestCase {
    func testKeywordsAllVariableContainsAllKeywords() {
        for keyword in iterateEnum(Step.Keyword.self) {
            XCTAssertTrue(Step.Keyword.all.contains(keyword))
        }
    }
}
