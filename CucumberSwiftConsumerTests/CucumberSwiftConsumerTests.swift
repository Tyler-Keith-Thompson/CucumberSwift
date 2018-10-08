//
//  CucumberSwiftConsumerTests.swift
//  CucumberSwiftConsumerTests
//
//  Created by Tyler Thompson on 8/25/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import XCTest
import CucumberSwift

extension Cucumber: StepImplementation {
    public func setupSteps() {
        var beforeFeatureCalled = 0
        BeforeFeature { _ in
            beforeFeatureCalled += 1
        }
        var beforeScenarioCalled = 0
        BeforeScenario { _ in
            beforeScenarioCalled += 1
        }
        var beforeStepCalled = 0
        BeforeStep { _ in
            beforeStepCalled += 1
        }
        var afterStepCalled = 0
        AfterStep { _ in
            afterStepCalled += 1
        }
        var afterScenarioCalled = 0
        AfterScenario { _ in
            afterScenarioCalled += 1
        }
        var afterFeatureCalled = 0
        AfterFeature { _ in
            afterFeatureCalled += 1
        }
        Given("^I have a before feature hook$") { _, _ in
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
        When("^I run the tests$") { _, _ in
            XCTAssert(true)
        }
        Then("^BeforeFeature gets called once per feature$") { _, _ in
            XCTAssertEqual(beforeFeatureCalled, 1)
        }
        Then("^BeforeScenario gets called once per scenario$") { _, _ in
            XCTAssertEqual(beforeScenarioCalled, 2)
        }
        Then("^BeforeStep gets called once per step$") { _, _ in
            XCTAssertEqual(beforeStepCalled, 9)
        }
        Then("^AfterStep gets called once per step$") { _, _ in
            XCTAssertEqual(afterStepCalled, 11)
        }
        Then("^AfterScenario gets called once per scenario$") { _, _ in
            XCTAssertEqual(afterScenarioCalled, 4)
        }
        Then("^AfterFeature gets called once per feature$") { _, _ in
            XCTAssertEqual(afterFeatureCalled, 1)
        }
        Then("^The scenario runs without crashing$") { _, _ in
            XCTAssert(true)
        }
        And("^The steps are slightly different$") { _, _ in
            XCTAssert(true)
        }
    }
}
