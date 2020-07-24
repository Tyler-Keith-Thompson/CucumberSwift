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
}
