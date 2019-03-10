//
//  ReporterTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 3/10/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

extension Feature {
    convenience init(uri:String) {
        self.init(with: FeatureNode(node: Node()), uri: uri)
    }
}

class ReporterTests: XCTestCase {
    override func setUp() {
        try? FileManager.default.removeItem(at: Reporter().reportURL!)
    }
    func testReporterWritesToDocuments() {
        let reporter = Reporter()
        reporter.write([
            ["find": "me"]
        ])
        XCTAssertEqual(reporter.currentJSON?.first?["find"] as? String, "me")
        try? FileManager.default.removeItem(at: reporter.reportURL!)
        XCTAssertNil(reporter.currentJSON)
    }
    
    func testFeatureIsOnlyWrittenIfItIsNotInFile() {
        let reporter = Reporter()
        let feature = Feature(uri: "findme")

        reporter.writeFeatureIfNecessary(feature)

        XCTAssertEqual(reporter.currentJSON?.first?.keys, feature.toJSON().keys)

        reporter.writeFeatureIfNecessary(feature)
        XCTAssertEqual(reporter.currentJSON?.count, 1)
    }
    
    func testScenarioIsOnlyWrittenIfItIsNotInFile() {
        let reporter = Reporter()
        let feature = Feature(uri: "findme")
        let scenario = Scenario(with: [], title: "findscn", tags: [])
        feature.addScenario(scenario)
        scenario.feature = feature
        
        reporter.writeScenarioIfNecessary(scenario)

        let featureJSON = reporter.currentJSON?.first
        XCTAssertNotNil(featureJSON)
        
        let scenarios = featureJSON?["elements"] as? [[String:Any]]
        XCTAssertNotNil(scenarios?.first)

        reporter.writeScenarioIfNecessary(scenario)
        XCTAssertEqual((reporter.currentJSON?.first?["elements"] as? [[String:Any]])?.count, 1)
    }
    
    func testStepIsWrittenToFile() {
        let reporter = Reporter()
        let step = Step(with: StepNode(node: Node()))
        let feature = Feature(uri: "findme")
        let scenario = Scenario(with: [step], title: "findscn", tags: [])
        step.scenario = scenario
        feature.addScenario(scenario)
        scenario.feature = feature

        reporter.writeStep(step)
        let featureJSON = reporter.currentJSON?.first
        XCTAssertNotNil(featureJSON)
        
        let scenarios = featureJSON?["elements"] as? [[String:Any]]
        XCTAssertNotNil(scenarios?.first)

        let steps = scenarios?.first?["steps"] as? [[String:Any]]
        XCTAssertNotNil(steps?.first)
    }
}
