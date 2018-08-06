//
//  TableTests.swift
//  CucumberSwiftTests
//
//  Created by dev1 on 7/17/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

class TableTests: XCTestCase {
    let tableFile: String =
    """
    Feature: Some terse yet descriptive text of what is desired
        Textual description of the business value of this feature
        Business rules that govern the scope of the feature
        Any additional information that will make the feature easier to understand

        Scenario Outline: Some determinable business situation
            Given some <precondition>
                And some <other precondition>
            When some action by <actor>
            Then some <testable outcome> is achieved

            Examples:
                | precondition  | other precondition    | actor | testable outcome  |
                | first         | second                | Bob   | result 1          |
                | third         | fourth                | Susan | result 2          |
    """

    func testTableDataIsDuplicatedAcrossScenarios() {
        let cucumber = Cucumber(withString: tableFile)
        let feature = cucumber.features.first
        let firstScenario = feature?.scenarios.first
        let secondScenario = feature?.scenarios.last
        XCTAssertEqual(feature?.scenarios.count, 2)
        XCTAssertEqual(firstScenario?.steps.count, 4)
        XCTAssertEqual(secondScenario?.steps.count, 4)
        XCTAssertEqual(firstScenario?.title, "Some determinable business situation")
        XCTAssertEqual(secondScenario?.title, "Some determinable business situation")
        if ((firstScenario?.steps.count ?? 0) == 4) {
            let steps = firstScenario?.steps
            XCTAssertEqual(steps?[0].keyword, .given)
            XCTAssertEqual(steps?[0].match, "some first")
            XCTAssertEqual(steps?[1].keyword, .and)
            XCTAssertEqual(steps?[1].match, "some second")
            XCTAssertEqual(steps?[2].keyword, .when)
            XCTAssertEqual(steps?[2].match, "some action by Bob")
            XCTAssertEqual(steps?[3].keyword, .then)
            XCTAssertEqual(steps?[3].match, "some result 1 is achieved")
        }
        if ((secondScenario?.steps.count ?? 0) == 4) {
            let steps = secondScenario?.steps
            XCTAssertEqual(steps?[0].keyword, .given)
            XCTAssertEqual(steps?[0].match, "some third")
            XCTAssertEqual(steps?[1].keyword, .and)
            XCTAssertEqual(steps?[1].match, "some fourth")
            XCTAssertEqual(steps?[2].keyword, .when)
            XCTAssertEqual(steps?[2].match, "some action by Susan")
            XCTAssertEqual(steps?[3].keyword, .then)
            XCTAssertEqual(steps?[3].match, "some result 2 is achieved")
        }
    }
    
    func testScenarioOutlinesHandleBackgroundSteps() {
        let cucumber = Cucumber(withString:"""
    Feature: Some terse yet descriptive text of what is desired
        Textual description of the business value of this feature
        Business rules that govern the scope of the feature
        Any additional information that will make the feature easier to understand
        
        Background:
            Given I am logged in
    
        Scenario Outline: Some determinable business situation
            Given some <precondition>
                And some <other precondition>
            When some action by <actor>
            Then some <testable outcome> is achieved

            Examples:
                | precondition  | other precondition    | actor | testable outcome  |
                | first         | second                | Bob   | result 1          |
                | third         | fourth                | Susan | result 2          |
    """)
        let feature = cucumber.features.first
        XCTAssertEqual(feature?.scenarios.count, 2)
        feature?.scenarios.forEach({ (scenario) in
            XCTAssertEqual(scenario.title, "Some determinable business situation")
            XCTAssertEqual(scenario.steps.count, 5)
        })
    }
    
    func testScenarioOutlinesHandleTags() {
        let cucumber = Cucumber(withString:"""
    Feature: Some terse yet descriptive text of what is desired
        Textual description of the business value of this feature
        Business rules that govern the scope of the feature
        Any additional information that will make the feature easier to understand
        
        Background:
            Given I am logged in
    
        @outline
        Scenario Outline: Some determinable business situation
            Given some <precondition>
                And some <other precondition>
            When some action by <actor>
            Then some <testable outcome> is achieved

            Examples:
                | precondition  | other precondition    | actor | testable outcome  |
                | first         | second                | Bob   | result 1          |
                | third         | fourth                | Susan | result 2          |
    """)
        let feature = cucumber.features.first
        XCTAssertEqual(feature?.scenarios.count, 2)
        feature?.scenarios.forEach({ (scenario) in
            XCTAssertEqual(scenario.title, "Some determinable business situation")
            XCTAssertEqual(scenario.steps.count, 5)
            XCTAssert(scenario.containsTag("outline"))
        })
    }
    
    func testTableHeadersInsideTitle() {
        let cucumber = Cucumber(withString:"""
    Feature: Some terse yet descriptive text of what is desired
      Scenario Outline: the <one>
        Given the <four>
            
            Examples:
              | one | two  | three | four   | five  |
              | un  | deux | trois | quatre | cinq  |
              | uno | dos  | tres  | quatro | cinco |
    """)
        let firstScenario = cucumber.features.first?.scenarios.first
        let secondScenario = cucumber.features.first?.scenarios.last
        XCTAssertEqual(firstScenario?.title, "the un")
        XCTAssertEqual(secondScenario?.title, "the uno")
    }
    
    func testTestDataAttachedToAStep() {
        let cucumber = Cucumber(withString:"""
    Feature: Some terse yet descriptive text of what is desired
        Scenario: minimalistic
            Given a simple data table
            | foo | bar |
            | boz | boo |
    """)
        let scenario = cucumber.features.first?.scenarios.first
        let step = scenario?.steps.first
        let table = step?.dataTable
        let firstRow = table?.rows.first
        let secondRow = table?.rows.last
        XCTAssertNotNil(step?.dataTable)
        XCTAssertEqual(table?.rows.count, 2)
        XCTAssertEqual(firstRow?.count, 2)
        XCTAssertEqual(secondRow?.count, 2)
        if ((firstRow?.count ?? 0) == 2) {
            XCTAssertEqual(firstRow?[0], "foo")
            XCTAssertEqual(firstRow?[1], "bar")
        }
        if ((secondRow?.count ?? 0) == 2) {
            XCTAssertEqual(secondRow?[0], "boz")
            XCTAssertEqual(secondRow?[1], "boo")
        }
        var givenCalled = false
        if (step?.dataTable != nil) {
            cucumber.Given("^a simple data table$") { (_, step) in
                givenCalled = true
                let dt = step.dataTable!
                let firstRow = dt.rows.first!
                let secondRow = dt.rows.last!
                XCTAssertEqual(firstRow[0], "foo")
                XCTAssertEqual(firstRow[1], "bar")
                XCTAssertEqual(secondRow[0], "boz")
                XCTAssertEqual(secondRow[1], "boo")
            }
        }
        cucumber.executeFeatures()
        XCTAssert(givenCalled)
    }
}
