//
//  StepTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 7/22/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

class StepTest: XCTestCase {
    func testAsteriskMatchesToGiven() {
        let cucumber = Cucumber(withString: """
    Feature: Some feature
       Scenario: Some determinable business situation
         * a user with half a clue
    """)
        let feature = cucumber.features.first
        let scenario = feature?.scenarios.first
        let firstStep = scenario?.steps.first
        XCTAssertEqual(scenario?.steps.count, 1)
        XCTAssert(firstStep?.keyword?.contains(.given) ?? false)
        XCTAssertEqual(firstStep?.match, "a user with half a clue")
        var givenCalled = false
        cucumber.Given("a user with half a clue") { _, _ in
            givenCalled = true
        }
        cucumber.executeFeatures()
        XCTAssert(givenCalled)
    }

    func testAsteriskMatchesToWhen() {
        let cucumber = Cucumber(withString: """
    Feature: Some feature
       Scenario: Some determinable business situation
         * a user with half a clue
    """)
        let feature = cucumber.features.first
        let scenario = feature?.scenarios.first
        let firstStep = scenario?.steps.first
        XCTAssertEqual(scenario?.steps.count, 1)
        XCTAssert(firstStep?.keyword?.contains(.when) ?? false)
        XCTAssertEqual(firstStep?.match, "a user with half a clue")
        var whenCalled = false
        cucumber.When("a user with half a clue") { _, _ in
            whenCalled = true
        }
        cucumber.executeFeatures()
        XCTAssert(whenCalled)
    }
    
    func testAsteriskMatchesToThen() {
        let cucumber = Cucumber(withString: """
    Feature: Some feature
       Scenario: Some determinable business situation
         * a user with half a clue
    """)
        let feature = cucumber.features.first
        let scenario = feature?.scenarios.first
        let firstStep = scenario?.steps.first
        XCTAssertEqual(scenario?.steps.count, 1)
        XCTAssert(firstStep?.keyword?.contains(.then) ?? false)
        XCTAssertEqual(firstStep?.match, "a user with half a clue")
        var thenCalled = false
        cucumber.Then("a user with half a clue") { _, _ in
            thenCalled = true
        }
        cucumber.executeFeatures()
        XCTAssert(thenCalled)
    }
    
    func testAsteriskMatchesToAnd() {
        let cucumber = Cucumber(withString: """
    Feature: Some feature
       Scenario: Some determinable business situation
         * a user with half a clue
    """)
        let feature = cucumber.features.first
        let scenario = feature?.scenarios.first
        let firstStep = scenario?.steps.first
        XCTAssertEqual(scenario?.steps.count, 1)
        XCTAssert(firstStep?.keyword?.contains(.and) ?? false)
        XCTAssertEqual(firstStep?.match, "a user with half a clue")
        var andCalled = false
        cucumber.And("a user with half a clue") { _, _ in
            andCalled = true
        }
        cucumber.executeFeatures()
        XCTAssert(andCalled)
    }
    
    func testAsteriskMatchesToBut() {
        let cucumber = Cucumber(withString: """
    Feature: Some feature
       Scenario: Some determinable business situation
         * a user with half a clue
    """)
        let feature = cucumber.features.first
        let scenario = feature?.scenarios.first
        let firstStep = scenario?.steps.first
        XCTAssertEqual(scenario?.steps.count, 1)
        XCTAssert(firstStep?.keyword?.contains(.but) ?? false)
        XCTAssertEqual(firstStep?.match, "a user with half a clue")
        var butCalled = false
        cucumber.But("a user with half a clue") { _, _ in
            butCalled = true
        }
        cucumber.executeFeatures()
        XCTAssert(butCalled)
    }
    
    func testAsteriskMatchesToMatchAll() {
        let cucumber = Cucumber(withString: """
    Feature: Some feature
       Scenario: Some determinable business situation
         * a user with half a clue
    """)
        let feature = cucumber.features.first
        let scenario = feature?.scenarios.first
        let firstStep = scenario?.steps.first
        XCTAssertEqual(scenario?.steps.count, 1)
        XCTAssertEqual(firstStep?.match, "a user with half a clue")
        var matchAllCalled = false
        cucumber.MatchAll("a user with half a clue") { _, _ in
            matchAllCalled = true
        }
        cucumber.executeFeatures()
        XCTAssert(matchAllCalled)
    }
}
