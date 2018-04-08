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
           #And something else we can check happens too

       Scenario: Some other determinable business situation
         Given some precondition
           And some other precondition
         When some action by the actor
         Then some testable outcome is achieved
    """

    func testExample() {
        self.measure {
            _ = Cucumber(with:
                repeatElement(featureFile, count: 1000)
                    .joined(separator: "\n"))
        }
    }
    
    func testGherkinIsParcedIntoCorrectFeaturesScenariosAndSteps() {
        let cucumber = Cucumber(with: featureFile)
        let feature = cucumber.features.first
        let firstScenario = cucumber.features.first?.scenarios.first
        let lastScenario = cucumber.features.first?.scenarios.last
        
        XCTAssertEqual(cucumber.features.count, 1)
        XCTAssertEqual(feature?.title, "Some terse yet descriptive text of what is desired")
        XCTAssertEqual(feature?.description, "Textual description of the business value of this feature\nBusiness rules that govern the scope of the feature\nAny additional information that will make the feature easier to understand\n")
        
        XCTAssertEqual(feature?.scenarios.count, 2)
        XCTAssertEqual(firstScenario?.title, "Some determinable business situation")
        XCTAssertEqual(firstScenario?.steps.count, 6)
        if ((firstScenario?.steps.count ?? 0) == 6) {
            let steps = firstScenario?.steps
            XCTAssertEqual(steps?[0].keyword, .given)
            XCTAssertEqual(steps?[0].match, "some precondition")
            XCTAssertEqual(steps?[1].keyword, .and)
            XCTAssertEqual(steps?[1].match, "some other precondition")
            XCTAssertEqual(steps?[2].keyword, .when)
            XCTAssertEqual(steps?[2].match, "some action by the actor")
            XCTAssertEqual(steps?[3].keyword, .and)
            XCTAssertEqual(steps?[3].match, "some other action")
            XCTAssertEqual(steps?[4].keyword, .and)
            XCTAssertEqual(steps?[4].match, "yet another action")
            XCTAssertEqual(steps?[5].keyword, .then)
            XCTAssertEqual(steps?[5].match, "some testable outcome is achieved")
        }
        
        XCTAssertEqual(lastScenario?.steps.count, 4)
        if ((lastScenario?.steps.count ?? 0) == 4) {
            let steps = lastScenario?.steps
            XCTAssertEqual(steps?[0].keyword, .given)
            XCTAssertEqual(steps?[0].match, "some precondition")
            XCTAssertEqual(steps?[1].keyword, .and)
            XCTAssertEqual(steps?[1].match, "some other precondition")
            XCTAssertEqual(steps?[2].keyword, .when)
            XCTAssertEqual(steps?[2].match, "some action by the actor")
            XCTAssertEqual(steps?[3].keyword, .then)
            XCTAssertEqual(steps?[3].match, "some testable outcome is achieved")
        }
    }
    
    func testFeatureHooks() {
        let cucumber = Cucumber(with: featureFile)
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
        let cucumber = Cucumber(with: featureFile)
        var beforeScenarioCalled = 0
        cucumber.BeforeScenario = { _ in
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
        let cucumber = Cucumber(with: featureFile)
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
//        let bundle = Bundle(for: CucumberSwiftTests.self)
//
//        Cucumberish.executeFeatures(inDirectory: "Features", from: bundle)

        let cucumber = Cucumber(with: featureFile)
        var givenCalled = false
        cucumber.Given("s(.)me (?:precondition)") { matches in
            givenCalled = true
            XCTAssertEqual(matches.count, 2)
            XCTAssertEqual(matches.last, "o")
        }
        cucumber.executeFeatures()
        XCTAssertTrue(givenCalled)

        var whenCalled = false
        cucumber.When("(.*?)") { matches in
            whenCalled = true
            XCTAssertEqual(matches.count, 2)
        }
        cucumber.executeFeatures()
        XCTAssertTrue(whenCalled)

        var thenCalled = false
        cucumber.Then("(.*?)") { matches in
            thenCalled = true
            XCTAssertEqual(matches.count, 2)
        }
        cucumber.executeFeatures()
        XCTAssertTrue(thenCalled)

        var andCalled = false
        cucumber.And("(.*?)") { matches in
            andCalled = true
            XCTAssertEqual(matches.count, 2)
        }
        cucumber.executeFeatures()
        XCTAssertTrue(andCalled)

        var orCalled = false
        cucumber.Or("(.*?)") { matches in
            orCalled = true
            XCTAssertEqual(matches.count, 1)
        }
        cucumber.executeFeatures()
        XCTAssertFalse(orCalled)

        var butCalled = false
        cucumber.But("(.*?)") { matches in
            butCalled = true
            XCTAssertEqual(matches.count, 1)
        }
        cucumber.executeFeatures()
        XCTAssertFalse(butCalled)

        var matchAllCalled = false
        cucumber.MatchAll("(.*?)") { matches in
            matchAllCalled = true
            XCTAssertEqual(matches.count, 2)
        }
        cucumber.executeFeatures()
        XCTAssertTrue(matchAllCalled)
    }
}
