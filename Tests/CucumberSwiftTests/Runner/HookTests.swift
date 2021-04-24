//
//  HookTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 4/24/21.
//  Copyright © 2021 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@testable import CucumberSwift

class HookTests: XCTestCase {
    override func setUpWithError() throws {
        Cucumber.shared.reset()
    }

    override func tearDownWithError() throws {
        Cucumber.shared.reset()
    }

    func testBeforeFeatureHookTriggersAppropriately() {
        Cucumber.shared.parseIntoFeatures("""
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

        var executionOrder = [String]()
        BeforeFeature { feature in
            executionOrder.append("BeforeFeature")
            XCTAssertEqual(feature.title, "Some terse yet descriptive text of what is desired")
        }

        Given("some precondition") { _, _ in executionOrder.append("Given") }

        Cucumber.shared.executeFeatures()

        XCTAssertEqual(executionOrder, ["BeforeFeature", "Given"])
    }

    func testBeforeScenarioHookTriggersAppropriately() {
        Cucumber.shared.parseIntoFeatures("""
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

        var executionOrder = [String]()
        BeforeFeature { feature in
            executionOrder.append("BeforeFeature")
            XCTAssertEqual(feature.title, "Some terse yet descriptive text of what is desired")
        }

        BeforeScenario { scenario in
            executionOrder.append("BeforeScenario_\(scenario.title)")
        }

        Given("some precondition") { _, _ in executionOrder.append("Given some precondition") }
        Given("some other precondition") { _, _ in executionOrder.append("Given some other precondition") }

        Cucumber.shared.executeFeatures()

        XCTAssertEqual(executionOrder, [
                        "BeforeFeature",
                        "BeforeScenario_Some determinable business situation",
                        "Given some precondition",
                        "BeforeScenario_Some other determinable business situation",
                        "Given some other precondition"
        ])
    }

    func testBeforeStepHookTriggersAppropriately() {
        Cucumber.shared.parseIntoFeatures("""
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

        var executionOrder = [String]()
        BeforeFeature { feature in
            executionOrder.append("BeforeFeature")
            XCTAssertEqual(feature.title, "Some terse yet descriptive text of what is desired")
        }

        BeforeScenario { scenario in
            executionOrder.append("BeforeScenario_\(scenario.title)")
        }

        BeforeStep { step in
            executionOrder.append("BeforeStep_\(step.match)")
        }

        Given("some precondition") { _, _ in executionOrder.append("Given some precondition") }
        Given("some other precondition") { _, _ in executionOrder.append("Given some other precondition") }

        Cucumber.shared.executeFeatures()

        XCTAssertEqual(executionOrder, [
                        "BeforeFeature",
                        "BeforeScenario_Some determinable business situation",
                        "BeforeStep_some precondition",
                        "Given some precondition",
                        "BeforeStep_some action is performed",
                        "BeforeStep_some testable result is achieved",
                        "BeforeScenario_Some other determinable business situation",
                        "BeforeStep_some other precondition",
                        "Given some other precondition",
                        "BeforeStep_some action is performed",
                        "BeforeStep_some testable result is achieved"
        ])
    }
}
