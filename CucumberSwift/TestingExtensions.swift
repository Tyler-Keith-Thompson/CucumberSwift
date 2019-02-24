//
//  TestingExtensions.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 2/24/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

extension Cucumber {
    /// Create an unfulfilled expectation.
    ///
    /// - Parameter description: the expectation description
    /// - Returns: the new expectation
    ///
    func expectation(description: String) -> XCTestExpectation {
        return XCTestExpectation(description: description)
    }
    
    /// Wait for a list of expectations to be fulfilled.
    ///
    /// - Parameters:
    ///   - expectations: the expectations to wait for
    ///   - seconds: the wait timeout
    ///
    func wait(for expectations: [XCTestExpectation], timeout seconds: TimeInterval) {
        XCTWaiter().wait(for: expectations, timeout: seconds)
    }
}
