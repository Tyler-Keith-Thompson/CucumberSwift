//
//  DSLFeatureTests.swift
//  CucumberSwiftTests
//
//  Created by thompsty on 7/23/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

class DSLFeatureTests: XCTestCase {
    override func setUpWithError() throws {
        Cucumber.shared.reset()
    }

    override func tearDownWithError() throws {
        Cucumber.shared.reset()
    }

    func getCurrentFilePath(file: StaticString = #file) -> String {
        String(file)
    }

    func testFeatureTags() {
        let featureTitle = UUID().uuidString
        let feature =
        Feature(featureTitle, tags: ["tag1", "tag2"]) {
            Scenario("") {
                Given(I: print(""))
            }
        }

        XCTAssertEqual(feature.tags, ["tag1", "tag2"])
        XCTAssertEqual(feature.title, featureTitle)
        XCTAssertEqual(feature.location.line, 29)
        XCTAssertEqual(feature.location.column, 16)
        XCTAssertEqual(feature.uri, getCurrentFilePath())
    }

    func testFeatureIsAddedToSharedCucumberInstance() {
        let feature =
        Feature("") {
            Scenario("") {
                Given(I: print(""))
            }
        }

        XCTAssertEqual(Cucumber.shared.features.count, 1)
        XCTAssert(Cucumber.shared.features.first === feature)
    }

    func testFeatureWithMultipleScenariosIsAddedToSharedCucumberInstance() {
        let feature =
        Feature("") {
            Scenario("") {
                Given(I: print(""))
            }
            Scenario("") {
                Given(I: print(""))
            }
        }

        XCTAssertEqual(Cucumber.shared.features.count, 1)
        XCTAssert(Cucumber.shared.features.first === feature)
    }

    func testStepExecutesWithTheCucumberRunner() {
        var called = false
        let stepExecutes = {
            called = true
        }
        Feature("") {
            Scenario("") {
                Given(a: stepExecutes())
            }
        }

        Cucumber.shared.executeFeatures()

        XCTAssert(called)
    }

    func testDSLShouldLoadWithLine() {
        var called = 0
        let stepExecutes = {
            called += 1
        }

        Cucumber.shouldRunWith = { scenario, _ in
            shouldRun(scenario?.withLine(96))
        }

        Feature("") {
            Scenario("First", tags: ["t1"]) {
                Given(a: stepExecutes())
            }
            Scenario("Second", tags: ["t2", "t3"]) {
                Given(a: stepExecutes())
            }
            Scenario("Third", tags: ["t1", "t2"]) {
                Given(a: stepExecutes())
            }
        }

        Cucumber.shared.executeFeatures()

        XCTAssertEqual(called, 1)
    }

    func testDSLShouldLoadWithScenarioTitle() {
        var called = 0
        let stepExecutes = {
            called += 1
        }

        Cucumber.shouldRunWith = { scenario, _ in
            scenario?.title == "First"
        }

        Feature("") {
            Scenario("First") {
                Given(a: stepExecutes())
            }
            Scenario("Second") {
                Given(a: stepExecutes())
            }
        }

        Cucumber.shared.executeFeatures()

        XCTAssertEqual(called, 1)
    }

    func testDSLShouldLoadWithTags() {
        var called = 0
        let stepExecutes = {
            called += 1
        }

        Cucumber.shouldRunWith = { _, tags in
            tags.contains("t1")
        }

        Feature("") {
            Scenario("First", tags: ["t1"]) {
                Given(a: stepExecutes())
            }
            Scenario("Second", tags: ["t2", "t3"]) {
                Given(a: stepExecutes())
            }
            Scenario("Third", tags: ["t1", "t2"]) {
                Given(a: stepExecutes())
            }
        }

        Cucumber.shared.executeFeatures()

        XCTAssertEqual(called, 2)
    }
}
