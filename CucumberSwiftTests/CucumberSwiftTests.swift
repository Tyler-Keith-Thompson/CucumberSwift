//
//  CucumberSwiftTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import XCTest
@testable import CucumberSwift

class CucumberSwiftTests: XCTestCase {
    let featureFile: String =
    """
    Feature: Some terse yet descriptive text of what is desired
       Textual description of the business value of this feature
       Business rules that govern the scope of the feature
       Any additional information that will make the feature easier to understand

       Scenario: Some determinable business situation
         Given some precondition
           And some other precondition
         When some action by the actor
           And some other action
           And yet another action
         Then some testable outcome is achieved

       Scenario: Some other determinable business situation
         Given some precondition
           And some other precondition
         When some action by the actor
         Then some testable outcome is achieved
    """
    func testFeatureHooks() {
        Cucumber.shared.features.removeAll()
        Cucumber.shared.parseIntoFeatures(featureFile)
        var beforeFeatureCalled = 0
        BeforeFeature { _ in
            beforeFeatureCalled += 1
        }
        var afterFeatureCalled = 0
        AfterFeature { _ in
            afterFeatureCalled += 1
        }
        Cucumber.shared.executeFeatures()
        XCTAssertEqual(beforeFeatureCalled, 1)
        XCTAssertEqual(afterFeatureCalled, 1)
    }

    func testBeforeScenarioHooks() {
        Cucumber.shared.features.removeAll()
        Cucumber.shared.parseIntoFeatures(featureFile)
        var beforeScenarioCalled = 0
        BeforeScenario { scenario in
            XCTAssertNotNil(scenario.feature)
            beforeScenarioCalled += 1
        }
        var afterScenarioCalled = 0
        AfterScenario { _ in
            afterScenarioCalled += 1
        }
        Cucumber.shared.executeFeatures()
        XCTAssertEqual(beforeScenarioCalled, 2)
        XCTAssertEqual(afterScenarioCalled, 2)
    }

    func testBeforeStepHooks() {
        Cucumber.shared.features.removeAll()
        Cucumber.shared.parseIntoFeatures(featureFile)
        var beforeStepCalled = 0
        BeforeStep { _ in
            beforeStepCalled += 1
        }
        var afterStepCalled = 0
        AfterStep { _ in
            afterStepCalled += 1
        }
        Cucumber.shared.executeFeatures()
        XCTAssertEqual(beforeStepCalled, 10)
        XCTAssertEqual(afterStepCalled, 10)
    }

    func testStepsGetCallbacksAttachedCorrectly() {
        Cucumber.shared.readFromFeaturesFolder(in: Bundle(for: CucumberSwiftTests.self))
        var givenCalled = false
        Given("S(.)mE (?:precondition)") { matches, _  in
            givenCalled = true
            XCTAssertEqual(matches.count, 2)
            XCTAssertEqual(matches.last, "o")
        }
        Cucumber.shared.executeFeatures()
        XCTAssertTrue(givenCalled)

        var whenCalled = false
        When("(.*?)") { matches, _ in
            whenCalled = true
            XCTAssertEqual(matches.count, 2)
        }
        Cucumber.shared.executeFeatures()
        XCTAssertTrue(whenCalled)

        var thenCalled = false
        Then("(.*?)") { matches, _ in
            thenCalled = true
            XCTAssertEqual(matches.count, 2)
        }
        Cucumber.shared.executeFeatures()
        XCTAssertTrue(thenCalled)

        var andCalled = false
        And("(.*?)") { matches, _ in
            andCalled = true
            XCTAssertEqual(matches.count, 2)
        }
        Cucumber.shared.executeFeatures()
        XCTAssertTrue(andCalled)

        var butCalled = false
        But("(.*?)") { matches, _ in
            butCalled = true
            XCTAssertEqual(matches.count, 1)
        }
        Cucumber.shared.executeFeatures()
        XCTAssertFalse(butCalled)

        var matchAllCalled = false
        MatchAll("(.*?)") { matches, _ in
            matchAllCalled = true
            XCTAssertEqual(matches.count, 2)
        }
        Cucumber.shared.executeFeatures()
        XCTAssertTrue(matchAllCalled)
    }

    func testStepFailsIfObserverCallsBackWithFailure() {
        Cucumber.shared.features.removeAll()
        Cucumber.shared.currentStep = Step(with: StepNode())

        XCTAssertEqual(Cucumber.shared.currentStep?.result, .pending)

        let errorMessage = "You did something stupid"
        Cucumber.shared.testCase(XCTestCase(), didFailWithDescription: errorMessage, inFile: nil, atLine: 0)
        XCTAssertEqual(Cucumber.shared.currentStep?.result, .failed)
        XCTAssertEqual(Cucumber.shared.currentStep?.errorMessage, errorMessage)
    }
}
