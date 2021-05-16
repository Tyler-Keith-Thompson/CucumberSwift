//
//  ReporterTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 3/10/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//
// swiftlint:disable file_types_order force_unwrapping

import Foundation
import XCTest
@testable import CucumberSwift

class ReporterTests: XCTestCase {
//    func testReporterWritesToDocuments() {
//        let reporter = Reporter()
//        reporter.write([
//            ["find": "me"]
//        ])
//        XCTAssertEqual(reporter.currentJSON?.first?["find"] as? String, "me")
//        try? FileManager.default.removeItem(at: reporter.reportURL!)
//        XCTAssertNil(reporter.currentJSON)
//    }

    func testFeatureIsOnlyWrittenIfItIsNotInFile() {
        let reporter = MockReporter()
        let feature = Feature(uri: "findme")

        reporter.writeFeatureIfNecessary(feature)

        XCTAssertEqual(reporter.currentJSON?.first?.keys, feature.toJSON().keys)

        reporter.writeFeatureIfNecessary(feature)
        XCTAssertEqual(reporter.currentJSON?.count, 1)
    }

    func testScenarioIsOnlyWrittenIfItIsNotInFile() {
        let reporter = MockReporter()
        let feature =
        Feature("findme") {
            Scenario("findscn") {
                Given(I: print(""))
            }
        }

        let scenario = feature.scenarios.first!

        reporter.writeScenarioIfNecessary(scenario)

        let featureJSON = reporter.currentJSON?.first
        XCTAssertNotNil(featureJSON)

        let scenarios = featureJSON?["elements"] as? [[String: Any]]
        XCTAssertNotNil(scenarios?.first)

        reporter.writeScenarioIfNecessary(scenario)
        XCTAssertEqual((reporter.currentJSON?.first?["elements"] as? [[String: Any]])?.count, 1)
    }

    func testStepIsWrittenToFile() {
        let reporter = MockReporter()
        let step = Given(I: print(""))
        let step2 = Given(I: print(""))
        Feature("findme") {
            Scenario("findscn") {
                step
                step2
            }
        }

        reporter.writeStep(step)
        reporter.writeStep(step2)
        let featureJSON = reporter.currentJSON?.first
        XCTAssertNotNil(featureJSON)

        let scenarios = featureJSON?["elements"] as? [[String: Any]]
        XCTAssertNotNil(scenarios?.first)

        let steps = scenarios?.first?["steps"] as? [[String: Any]]
        XCTAssertNotNil(steps?.first)
        XCTAssertEqual(steps?.count, 2)
    }

    func testStepDurationIsAccuratelyWrittenToFile() {
        let reporter = MockReporter()
        let step = Given(I: print(""))
        let d = Date()
        step.startTime = d
        step.endTime = d.addingTimeInterval(1)
        Feature("findme") {
            Scenario("findscn") {
                step
            }
        }

        let duration = step.executionDuration.converted(to: .nanoseconds).value
        XCTAssertEqual(duration, 1_000_000_000)

        reporter.writeStep(step)

        let featureJSON = reporter.currentJSON?.first
        let scenarios = featureJSON?["elements"] as? [[String: Any]]
        let steps = scenarios?.first?["steps"] as? [[String: Any]]
        XCTAssertEqual((steps?.first?["result"] as? [String: Any])?["duration"] as? Double, duration)
    }
}

class MockReporter: Reporter {
    var writeCalled = 0
    var lastDict: [[String: Any]] = []

    override var currentJSON: [[String: Any]]? { lastDict }

    override func write(_ dict: [[String: Any]]) {
        writeCalled += 1
        lastDict = dict
    }
}

extension Feature {
    convenience init(uri: String) {
        self.init(with: AST.FeatureNode(node: AST.Node()), uri: uri)
    }
}
