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
    
    override func setUp() {
        Cucumber.shared.features.removeAll()
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
        XCTAssertEqual(feature.location.line, 22)
        XCTAssertEqual(feature.location.column, 16)
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
    
    #warning("Need to test shouldLoadWith both with a line and with tags")
    //NOTE: Used to be that you could run a specific example in a ScenarioOutline by line number
    //That might be damn near impossible with the DSL without parsing the Swift AST directly
}
