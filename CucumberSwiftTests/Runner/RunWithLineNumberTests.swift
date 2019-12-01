//
//  RunWithLineNumberTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 11/30/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

class RunWithLineNumberTests: XCTestCase {
    func testRunOnSpecificExampleWithScenarioOutlines() {
        Cucumber.shouldRunWith = { scenario, _ in
            shouldRun(scenario?.withLine(9))
        }

        Cucumber.shared.features.removeAll()
        Cucumber.shared.parseIntoFeatures("""
        Feature: Some terse yet descriptive text of what is desired
           Scenario Outline: Some determinable business situation
             Given a <thing> with tags
             Then something different

            Examples:
            |  thing   |
            | scenario |
            | scenari0 | #line 9
        """)
        Cucumber.shared.environment["CUCUMBER_TAGS"] = nil

        XCTAssertEqual(Cucumber.shared.features.first?.scenarios.first?.location.line, 8)
        XCTAssertEqual(Cucumber.shared.features.first?.scenarios.last?.location.line, 9)

        var scenarioCalled = false
        Given("a scenario with tags") { _, _ in
            scenarioCalled = true
        }
        var scenari0Called = false
        Given("a scenari0 with tags") { _, _ in
            scenari0Called = true
        }

        Cucumber.shared.executeFeatures()
        
        XCTAssertFalse(scenarioCalled)
        XCTAssert(scenari0Called)
        Cucumber.shouldRunWith = { _, _ in true }
    }
    
    func testRunOnSpecificScenarioWithFuzzyLineNumber() {
        Cucumber.shouldRunWith = { scenario, _ in
            shouldRun(scenario?.withLine(4))
        }

        Cucumber.shared.features.removeAll()
        Cucumber.shared.parseIntoFeatures(
        """
        Feature: Some terse yet descriptive text of what is desired
           Scenario: Some determinable business situation
             Given some precondition
             When some action is performed
             Then some testable result is achieved

        Scenario: Some other determinable business situation
          Given some other precondition
          When some action is performed
          Then some testable result is achieved
        """)
        Cucumber.shared.environment["CUCUMBER_TAGS"] = nil

        var scenarioCalled = false
        Given("some precondition") { _, _ in
            scenarioCalled = true
        }
        var scenario1Called = false
        Given("some other precondition") { _, _ in
            scenario1Called = true
        }

        Cucumber.shared.executeFeatures()
        
        XCTAssert(scenarioCalled)
        XCTAssertFalse(scenario1Called)
        Cucumber.shouldRunWith = { _, _ in true }
    }
    
    func testRunOnEntireFeatureWithFuzzyLineNumber() {
        Cucumber.shouldRunWith = { scenario, _ in
            shouldRun(scenario?.feature?.withLine(4))
        }

        Cucumber.shared.features.removeAll()
        Cucumber.shared.parseIntoFeatures(
        """
        Feature: Some terse yet descriptive text of what is desired
           Scenario: Some determinable business situation
             Given some precondition
             When some action is performed
             Then some testable result is achieved

        Scenario: Some other determinable business situation
          Given some other precondition
          When some action is performed
          Then some testable result is achieved
        """)
        Cucumber.shared.environment["CUCUMBER_TAGS"] = nil

        var scenarioCalled = false
        Given("some precondition") { _, _ in
            scenarioCalled = true
        }
        var scenario1Called = false
        Given("some other precondition") { _, _ in
            scenario1Called = true
        }

        Cucumber.shared.executeFeatures()
        
        XCTAssert(scenarioCalled)
        XCTAssert(scenario1Called)
        Cucumber.shouldRunWith = { _, _ in true }
    }
}
