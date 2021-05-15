//
//  RuleTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 12/6/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import CucumberSwift

class RuleTests: XCTestCase {
    override func setUpWithError() throws {
        Cucumber.shared.reset()
    }

    override func tearDownWithError() throws {
        Cucumber.shared.reset()
    }

    func testSimpleRule() {
        Cucumber.shared.features.removeAll()
        Cucumber.shared.parseIntoFeatures("""
    Feature: Some rule

    Rule: A
      The rule A description

      Example: Example A
        Given a

      Scenario: Scenario B
        Given b
    """)
        let firstScenario = Cucumber.shared.features.first?.scenarios.first
        XCTAssertEqual(firstScenario?.steps.count, 1)
        XCTAssertEqual(firstScenario?.steps[safe: 0]?.keyword, .given)
        XCTAssertEqual(firstScenario?.steps[safe: 0]?.match, "a")

        let secondScenario = Cucumber.shared.features.first?.scenarios[safe: 1]
        XCTAssertEqual(secondScenario?.steps.count, 1)
        XCTAssertEqual(secondScenario?.steps[safe: 0]?.keyword, .given)
        XCTAssertEqual(secondScenario?.steps[safe: 0]?.match, "b")
    }

    func testMultipleRules() {
        Cucumber.shared.features.removeAll()
        Cucumber.shared.parseIntoFeatures("""
    Feature: Some rules

    Rule: A
      The rule A description

      Example: Example A
        Given a

    Rule: B
      The rule B description

      Example: Example B
        Given b
    """)
        let firstScenario = Cucumber.shared.features.first?.scenarios.first
        XCTAssertEqual(firstScenario?.steps.count, 1)
        XCTAssertEqual(firstScenario?.steps[safe: 0]?.keyword, .given)
        XCTAssertEqual(firstScenario?.steps[safe: 0]?.match, "a")

        let secondScenario = Cucumber.shared.features.first?.scenarios[safe: 1]
        XCTAssertEqual(secondScenario?.steps.count, 1)
        XCTAssertEqual(secondScenario?.steps[safe: 0]?.keyword, .given)
        XCTAssertEqual(secondScenario?.steps[safe: 0]?.match, "b")
    }

    func testRuleWithSeparateBackgroundSteps() {
        Cucumber.shared.features.removeAll()
        Cucumber.shared.parseIntoFeatures("""
    Feature: Some rules

    Background:
      Given fb

    Rule: A
      The rule A description

      Background:
        Given ab

      Example: Example A
        Given a

    Rule: B
      The rule B description

      Example: Example B
        Given b
    """)
        let firstScenario = Cucumber.shared.features.first?.scenarios.first
        XCTAssertEqual(firstScenario?.steps.count, 3)
        XCTAssertEqual(firstScenario?.steps[safe: 0]?.keyword, .given)
        XCTAssertEqual(firstScenario?.steps[safe: 0]?.match, "fb")
        XCTAssertEqual(firstScenario?.steps[safe: 1]?.keyword, .given)
        XCTAssertEqual(firstScenario?.steps[safe: 1]?.match, "ab")
        XCTAssertEqual(firstScenario?.steps[safe: 2]?.keyword, .given)
        XCTAssertEqual(firstScenario?.steps[safe: 2]?.match, "a")

        let secondScenario = Cucumber.shared.features.first?.scenarios[safe: 1]
        XCTAssertEqual(secondScenario?.steps.count, 2)
        XCTAssertEqual(secondScenario?.steps[safe: 0]?.keyword, .given)
        XCTAssertEqual(secondScenario?.steps[safe: 0]?.match, "fb")
        XCTAssertEqual(secondScenario?.steps[safe: 1]?.keyword, .given)
        XCTAssertEqual(secondScenario?.steps[safe: 1]?.match, "b")
    }
}
