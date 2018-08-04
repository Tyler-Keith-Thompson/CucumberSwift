//
//  StepGenerationTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 8/4/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

class StepGenerationTests:XCTestCase {
    func testGeneratedRegexWithGivenKeyword() {
        let cucumber = Cucumber(withString: """
        Feature: Some terse yet descriptive text of what is desired
           Scenario: Some determinable business situation
             Given Some precondition
        """)
        let actual = cucumber.generateUnimplementedStepDefinitions()
        let expected = """
        cucumber.Given("^Some precondition$") { _, _ in
        
        }
        """.replacingOccurrences(of: "\\", with: "\\\\", options: [], range: nil)
        XCTAssert(actual.contains(expected), "\"\(actual)\" does not contain \"\(expected)\"")
    }
    
    func testGeneratedRegexWithDifferentKeyword() {
        let cucumber = Cucumber(withString: """
        Feature: Some terse yet descriptive text of what is desired
           Scenario: Some determinable business situation
             When Some precondition
        """)
        let actual = cucumber.generateUnimplementedStepDefinitions()
        let expected = """
        cucumber.When("^Some precondition$") { _, _ in
        
        }
        """.replacingOccurrences(of: "\\", with: "\\\\", options: [], range: nil)
        XCTAssert(actual.contains(expected), "\"\(actual)\" does not contain \"\(expected)\"")
    }
    
    func testGeneratedRegexWithDifferentMatch() {
        let cucumber = Cucumber(withString: """
        Feature: Some terse yet descriptive text of what is desired
           Scenario: Some determinable business situation
             When A totally different string match
        """)
        let actual = cucumber.generateUnimplementedStepDefinitions()
        let expected = """
        cucumber.When("^A totally different string match$") { _, _ in
        
        }
        """.replacingOccurrences(of: "\\", with: "\\\\", options: [], range: nil)
        XCTAssert(actual.contains(expected), "\"\(actual)\" does not contain \"\(expected)\"")
    }
    
    func testGeneratedRegexWithLiteralsThatNeedToBeEscaped() {
        let cucumber = Cucumber(withString: """
        Feature: Some terse yet descriptive text of what is desired
           Scenario: Some determinable business situation
             Given A user with an idea(ish)
        """)
        let actual = cucumber.generateUnimplementedStepDefinitions()
        let expected = """
        cucumber.Given("^A user with an idea\\(ish\\)$") { _, _ in
        
        }
        """.replacingOccurrences(of: "\\", with: "\\\\", options: [], range: nil)
        XCTAssert(actual.contains(expected), "\"\(actual)\" does not contain \"\(expected)\"")
    }
    
    func testGeneratedRegexWithSomeStepsThatAreImplmentatedAndSomeThatAreNot() {
        let cucumber = Cucumber(withString: """
        Feature: Some terse yet descriptive text of what is desired
           Scenario: Some determinable business situation
             Given A user with an idea
              And A PO with two
        """)
        cucumber.Given("^A user with an idea$") { _, _ in
            
        }
        let actual = cucumber.generateUnimplementedStepDefinitions()
        let expected = """
        cucumber.And("^A PO with two$") { _, _ in
        
        }
        """.replacingOccurrences(of: "\\", with: "\\\\", options: [], range: nil)
        let notExpected = """
        cucumber.Given("^A user with an idea$") { _, _ in
        
        }
        """.replacingOccurrences(of: "\\", with: "\\\\", options: [], range: nil)
        
        XCTAssert(actual.contains(expected), "\"\(actual)\" does not contain \"\(expected)\"")
        XCTAssert(!actual.contains(notExpected), "\"\(actual)\" should not contain \"\(notExpected)\"")
    }
}
