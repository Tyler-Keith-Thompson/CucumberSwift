//
//  CucumberSwiftConsumerTests.swift
//  CucumberSwiftConsumerTests
//
//  Created by Tyler Thompson on 8/25/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import XCTest
import CucumberSwift

class Me:XCTestCase {
    static var unitTestSetupCalled = 0
    static var unitTestExecuted = false
    static var unitTestTearDownCalled = 0
    
    override func setUp() {
        Me.unitTestSetupCalled += 1
    }
    
    func unitTestIsExecuted() {
        Me.unitTestExecuted = true
    }
    
    override func tearDown() {
        Me.unitTestTearDownCalled += 1
    }
}

extension Feature : Hashable {
    public static func == (lhs: Feature, rhs: Feature) -> Bool {
        return lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(Unmanaged.passUnretained(self).toOpaque())
    }
}

extension Step : Hashable {
    public static func == (lhs: Step, rhs: Step) -> Bool {
        return lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(Unmanaged.passUnretained(self).toOpaque())
    }
}

extension Cucumber: StepImplementation {
    public var bundle: Bundle {
        return Bundle(for: Me.self)
    }
    
    public func setupSteps() {
        var beforeFeatureHooks = [Feature:Int]()
        BeforeFeature { feature in
            beforeFeatureHooks[feature, default: 0] += 1
        }
        var secondaryBeforeFeatureHooks = [Feature:Int]()
        BeforeFeature { feature in
            secondaryBeforeFeatureHooks[feature, default: 0] += 1
        }
        var beforeScenarioHooks = [Scenario:Int]()
        BeforeScenario { scenario in
            beforeScenarioHooks[scenario, default: 0] += 1
        }
        var beforeStepHooks = [Step:Int]()
        BeforeStep { step in
            beforeStepHooks[step, default: 0] += 1
        }
        var afterStepHooks = [Step:Int]()
        AfterStep { step in
            if (afterStepHooks[step] != nil) {
                XCTFail("Should not have the same after hook called")
            }
            afterStepHooks[step, default: 0] += 1
        }
        var afterScenarioHooks = [Scenario:Int]()
        AfterScenario { scenario in
            if (afterScenarioHooks[scenario] != nil) {
                XCTFail("Should not have the same after hook called")
            }
            afterScenarioHooks[scenario, default: 0] += 1
        }
        var afterFeatureHooks = [Feature:Int]()
        AfterFeature { feature in
            if (afterFeatureHooks[feature] != nil) {
                XCTFail("Should not have the same after hook called")
            }
            afterFeatureHooks[feature, default: 0] += 1
        }
        Given("^I have a before feature hook$") { _, _ in
            XCTAssert(true)
        }
        Given("^I have a before scenario outline hook$") { _, _ in
            XCTAssert(true)
        }
        Given("^I have a before scenario hook$") { _, _ in
            XCTAssert(true)
        }
        Given("^I have a before step hook$") { _, _ in
            XCTAssert(true)
        }
        Given("^I have an after step hook$") { _, _ in
            XCTAssert(true)
        }
        Given("^I have an after scenario hook$") { _, _ in
            XCTAssert(true)
        }
        Given("^I have an after feature hook$") { _, _ in
            XCTAssert(true)
        }
        Given("^I have a scenario defined$") { _, _ in
            XCTAssert(true)
        }
        Given("^I point my step to a unit test$", class:Me.self, selector: #selector(Me.unitTestIsExecuted))

        When("^I run the tests$") { _, _ in
            XCTAssert(true)
        }
        
        Then("^BeforeFeature gets called once per feature$") { _, step in
            XCTAssertEqual(beforeFeatureHooks[step.scenario!.feature!], 1)
            XCTAssertEqual(secondaryBeforeFeatureHooks[step.scenario!.feature!], 1)
        }
        Then("^BeforeScenario gets called once per scenario$") { _, step in
            XCTAssertEqual(beforeScenarioHooks[step.scenario!], 1)
        }
        Then("^BeforeScenario gets called once per scenario outline$") { _, step in
            XCTAssertEqual(beforeScenarioHooks[step.scenario!], 1)
        }
        Then("^BeforeStep gets called once per step$") { _, step in
            XCTAssertEqual(beforeStepHooks[step], 1)
        }
        Then("^AfterStep gets called once per step$") { _, _ in
            XCTAssert(afterStepHooks.keys.count > 0)
        }
        Then("^AfterScenario gets called once per scenario$") { _, _ in
            //gotta test this after the scenario...
        }
        Then("^AfterFeature gets called once per feature$") { _, _ in
            //gotta test this after the feature...
        }
        Then("^The scenario runs without crashing$") { _, _ in
            let expectation = self.expectation(description: "waiting")
            expectation.fulfill()
            self.wait(for: [expectation], timeout: 3)
            XCTAssert(true)
        }
        Then("^The unit test runs$") { _, _ in
            XCTAssertEqual(Me.unitTestSetupCalled, 1)
            XCTAssert(Me.unitTestExecuted, "Unit test did not run")
            XCTAssertEqual(Me.unitTestTearDownCalled, 1)
        }
        And("^The steps are slightly different$") { _, _ in
            XCTAssert(true)
        }
    }
}
