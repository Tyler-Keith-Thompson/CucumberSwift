//
//  CucumberSwiftTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
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
        let cucumber = Cucumber(withString: featureFile)
        var beforeFeatureCalled = 0
        cucumber.BeforeFeature = { _ in
            beforeFeatureCalled += 1
        }
        var afterFeatureCalled = 0
        cucumber.AfterFeature = { _ in
            afterFeatureCalled += 1
        }
        cucumber.executeFeatures()
        XCTAssertEqual(beforeFeatureCalled, 1)
        XCTAssertEqual(afterFeatureCalled, 1)
    }

    func testBeforeScenarioHooks() {
        let cucumber = Cucumber(withString: featureFile)
        var beforeScenarioCalled = 0
        cucumber.BeforeScenario = { scenario in
            XCTAssertNotNil(scenario.feature)
            beforeScenarioCalled += 1
        }
        var afterScenarioCalled = 0
        cucumber.AfterScenario = { _ in
            afterScenarioCalled += 1
        }
        cucumber.executeFeatures()
        XCTAssertEqual(beforeScenarioCalled, 2)
        XCTAssertEqual(afterScenarioCalled, 2)
    }

    func testBeforeStepHooks() {
        let cucumber = Cucumber(withString: featureFile)
        var beforeStepCalled = 0
        cucumber.BeforeStep = { _ in
            beforeStepCalled += 1
        }
        var afterStepCalled = 0
        cucumber.AfterStep = { _ in
            afterStepCalled += 1
        }
        cucumber.executeFeatures()
        XCTAssertEqual(beforeStepCalled, 10)
        XCTAssertEqual(afterStepCalled, 10)
    }
    
    func testStepsGetCallbacksAttachedCorrectly() {
        let bundle = Bundle(for: CucumberSwiftTests.self)
        let cucumber = Cucumber(withDirectory:"Features", inBundle: bundle)
        var givenCalled = false
        cucumber.Given("S(.)mE (?:precondition)") { matches, _  in
            givenCalled = true
            XCTAssertEqual(matches.count, 2)
            XCTAssertEqual(matches.last, "o")
        }
        cucumber.executeFeatures()
        XCTAssertTrue(givenCalled)

        var whenCalled = false
        cucumber.When("(.*?)") { matches, _ in
            whenCalled = true
            XCTAssertEqual(matches.count, 2)
        }
        cucumber.executeFeatures()
        XCTAssertTrue(whenCalled)

        var thenCalled = false
        cucumber.Then("(.*?)") { matches, _ in
            thenCalled = true
            XCTAssertEqual(matches.count, 2)
        }
        cucumber.executeFeatures()
        XCTAssertTrue(thenCalled)

        var andCalled = false
        cucumber.And("(.*?)") { matches, _ in
            andCalled = true
            XCTAssertEqual(matches.count, 2)
        }
        cucumber.executeFeatures()
        XCTAssertTrue(andCalled)

        var butCalled = false
        cucumber.But("(.*?)") { matches, _ in
            butCalled = true
            XCTAssertEqual(matches.count, 1)
        }
        cucumber.executeFeatures()
        XCTAssertFalse(butCalled)

        var matchAllCalled = false
        cucumber.MatchAll("(.*?)") { matches, _ in
            matchAllCalled = true
            XCTAssertEqual(matches.count, 2)
        }
        cucumber.executeFeatures()
        XCTAssertTrue(matchAllCalled)
    }
    
    func testStepFailsIfObserverCallsBackWithFailure() {
        let cucumber = Cucumber(withString: "")
        cucumber.currentStep = Step(with: StepNode())
        
        XCTAssertEqual(cucumber.currentStep?.result, .pending)
        
        let errorMessage = "You did something stupid"
        cucumber.testCase(XCTestCase(), didFailWithDescription: errorMessage, inFile: nil, atLine: 0)
        XCTAssertEqual(cucumber.currentStep?.result, .failed)
        XCTAssertEqual(cucumber.currentStep?.errorMessage, errorMessage)
    }
}
