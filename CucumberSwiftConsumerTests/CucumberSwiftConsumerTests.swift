//
//  CucumberSwiftConsumerTests.swift
//  CucumberSwiftConsumerTests
//
//  Created by Tyler Thompson on 8/25/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import XCTest
import CucumberSwift

class CucumberSwiftConsumerTests: CucumberTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
        Given("^I have a before feature hook$") { _, _ in
            XCTAssert(true)
        }
        Given("^I have a before scenario hook$") { _, _ in
            XCTAssert(true)
        }
        Given("^I have a before step hook$") { _, _ in
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
        Then("^The scenario runs without crashing$") { _, _ in
            XCTAssert(true)
        }
        And("^The steps are slightly different$") { _, _ in
            XCTAssert(true)
        }
    }
}
