//
//  StepTests.swift
//  CucumberSwiftTests
//
//  Created by thompsty on 7/22/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import CucumberSwift

class DSLStepTests: XCTestCase {
    func testBasicDSL() {
        func printAStatement() { print("Printed") }

        let featureTitle = UUID().uuidString
        let scenarioTitle = UUID().uuidString

        let feature =
        Feature(featureTitle) {
            Description(UUID().uuidString)
            Scenario(scenarioTitle) {
                Given(I: printAStatement())
            }
        }
        
        XCTAssertEqual(feature.title, featureTitle)
        XCTAssertEqual(feature.location.line, 21)
        XCTAssertEqual(feature.location.column, 16)
        XCTAssertEqual(feature.scenarios.count, 1)

        let scenario = feature.scenarios.first
        XCTAssertEqual(scenario?.title, scenarioTitle)
        XCTAssertEqual(scenario?.location.line, 23)
        XCTAssertEqual(scenario?.location.column, 21)
        XCTAssertEqual(scenario?.steps.count, 1)
        
        let step = scenario?.steps.first
        XCTAssertEqual(step?.match, "I: printAStatement()")
        XCTAssertEqual(step?.location.line, 24)
        XCTAssertEqual(step?.location.column, 22)
    }
    
    func testStepMatchWithWeirdFormatting() {
        func printAStatement() { print("Printed") }

        let feature =
        Feature("") {
            Description(UUID().uuidString)
            Scenario("") {
                Given(a:
                    printAStatement())
            }
        }
        
        let scenario = feature.scenarios.first
        let step = scenario?.steps.first
        XCTAssertEqual(step?.match, "a:printAStatement()")
        XCTAssertEqual(step?.location.line, 52)
        XCTAssertEqual(step?.location.column, 22)
    }

    func testStepMatchWithAsManyLineBreaksAsPossible() {
        func printAStatement() { print("Printed") }

        let feature =
        Feature("") {
            Description(UUID().uuidString)
            Scenario("") {
                Given(the:
                    printAStatement()
                )
            }
        }
        
        let scenario = feature.scenarios.first
        let step = scenario?.steps.first
        XCTAssertEqual(step?.match, "the:printAStatement()")
        XCTAssertEqual(step?.location.line, 71)
        XCTAssertEqual(step?.location.column, 22)
    }
    
    func testStepMatchWithAsStringLiteralThatTriesToFoolTheParenCount() {
        func printAStatement(_ str:String) { print(str) }
        
        let feature =
        Feature("") {
            Description(UUID().uuidString)
            Scenario("") {
                Given(my:
                    printAStatement("))")
                )
            }
        }
        
        let scenario = feature.scenarios.first
        let step = scenario?.steps.first
        XCTAssertEqual(step?.match, "my:printAStatement(\"))\")")
        XCTAssertEqual(step?.location.line, 91)
        XCTAssertEqual(step?.location.column, 22)
    }
    
    func testStepMatchWithAsStringLiteralThatDoesNotTryToFoolTheParenCount() {
        func printAStatement(_ str:String) { print(str) }
        
        let feature =
        Feature("") {
            Description(UUID().uuidString)
            Scenario("") {
                Given(some:
                    printAStatement("some other thing")
                )
            }
        }
        
        let scenario = feature.scenarios.first
        let step = scenario?.steps.first
        XCTAssertEqual(step?.match, "some:printAStatement(\"some other thing\")")
        XCTAssertEqual(step?.location.line, 111)
        XCTAssertEqual(step?.location.column, 22)
    }
    
    func testStepMatchWithAsDocStringLiteralThatDoesNotTryToFoolTheParenCount() {
        func printAStatement(_ str:String) { print(str) }
        
        let feature =
        Feature("") {
            Description(UUID().uuidString)
            Scenario("") {
                Given(I:
                    printAStatement("""
                        ""some o)her thing""
                    """)
                )
            }
        }
        
        let scenario = feature.scenarios.first
        let step = scenario?.steps.first
        XCTAssertEqual(step?.match, "I:printAStatement(\"\"\"\"\"some o)her thing\"\"\"\"\")")
        XCTAssertEqual(step?.location.line, 131)
        XCTAssertEqual(step?.location.column, 22)
    }
}
