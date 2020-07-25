//
//  DSLBackgroundTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 7/25/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import CucumberSwift

class DSLBackgroundTests: XCTestCase {
    func testBackgroundStepsAreAddedToOneScenario() {
        let feature =
        Feature("F1") {
            Background {
                Given(I: print("B1"))
            }
            Scenario("SC1") {
                When(I: print("S1"))
            }
        }
        
        XCTAssertEqual(feature.scenarios.count, 1)
        
        let sc1 = feature.scenarios.first
        XCTAssertEqual(sc1?.steps.count, 2)
        XCTAssertEqual(sc1?.steps.first?.match, "I: print(\"B1\")")
        XCTAssertEqual(sc1?.steps.last?.match, "I: print(\"S1\")")
    }
    
    func testBackgroundStepsAreAddedToMultipleScenarios() {
        let feature =
        Feature("F1") {
            Background {
                Given(I: print("B1"))
            }
            Scenario("SC1") {
                When(I: print("S1"))
            }
            Scenario("SC2") {
                When(I: print("S2"))
            }
        }
        
        XCTAssertEqual(feature.scenarios.count, 2)
        
        let sc1 = feature.scenarios.first
        XCTAssertEqual(sc1?.steps.count, 2)
        XCTAssertEqual(sc1?.steps.first?.match, "I: print(\"B1\")")
        XCTAssertEqual(sc1?.steps.last?.match, "I: print(\"S1\")")
        
        let sc2 = feature.scenarios.last
        XCTAssertEqual(sc2?.steps.count, 2)
        XCTAssertEqual(sc2?.steps.first?.match, "I: print(\"B1\")")
        XCTAssertEqual(sc2?.steps.last?.match, "I: print(\"S2\")")
    }
}
