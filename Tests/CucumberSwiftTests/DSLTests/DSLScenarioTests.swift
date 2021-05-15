//
//  DSLScenarioTests.swift
//  CucumberSwiftTests
//
//  Created by thompsty on 7/23/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import CucumberSwift

class DSLScenarioTests: XCTestCase {
    func testScenarioWithASingleStep() {
        let sawTheSign = { }
        let scenarioTitle = UUID().uuidString

        let scn =
        Scenario(scenarioTitle) {
            Then(I: sawTheSign())
        }

        XCTAssertEqual(scn.title, scenarioTitle)
        XCTAssertEqual(scn.steps.count, 1)

        let step = scn.steps.first
        XCTAssertEqual(step?.match, "I: sawTheSign()")
    }

    func testScenarioWithMultipleSteps() {
        let precondition = { }
        let actionByTheActor = { }
        let testableOutcomeIsAchieved = { }

        let scn =
        Scenario("Some determinable business situation") {
            Given(some: precondition())// .continueAfterFailure(false)
            When(some: actionByTheActor())
            Then(some: testableOutcomeIsAchieved())
        }

        XCTAssertEqual(scn.title, "Some determinable business situation")
        XCTAssertEqual(scn.steps.count, 3)

        var step = scn.steps.first
        XCTAssertEqual(step?.keyword, .given)
        XCTAssertEqual(step?.match, "some: precondition()")

        if scn.steps.count > 1 {
            step = scn.steps[1]
            XCTAssertEqual(step?.keyword, .when)
            XCTAssertEqual(step?.match, "some: actionByTheActor()")
        }

        step = scn.steps.last
        XCTAssertEqual(step?.keyword, .then)
        XCTAssertEqual(step?.match, "some: testableOutcomeIsAchieved()")
    }

    func testScenarioWithTags() {
        let sawTheSign = { }
        let openedUpMyEyes = { }
        let scenarioTitle = UUID().uuidString

        let scn =
        Scenario(scenarioTitle, tags: ["tag1", "tag2"]) {
            Then(I: sawTheSign())
                And(it: openedUpMyEyes())
        }

        XCTAssertEqual(scn.title, scenarioTitle)
        XCTAssertEqual(scn.tags, ["tag1", "tag2"])
    }
}
