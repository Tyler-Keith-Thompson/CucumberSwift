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

extension String {
    func stringByEscapingCharacters() -> String {
        return self.replacingOccurrences(of: "\\", with: "\\\\", options: [], range: nil)
//            .replacingOccurrences(of: "\"", with: "\\\"", options: [], range: nil)
    }
}
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
        """.stringByEscapingCharacters()
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
        """.stringByEscapingCharacters()
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
        """.stringByEscapingCharacters()
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
        """.stringByEscapingCharacters()
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
        """.stringByEscapingCharacters()
        let notExpected = """
        cucumber.Given("^A user with an idea$") { _, _ in
        
        }
        """.stringByEscapingCharacters()
        
        XCTAssert(actual.contains(expected), "\"\(actual)\" does not contain \"\(expected)\"")
        XCTAssert(!actual.contains(notExpected), "\"\(actual)\" should not contain \"\(notExpected)\"")
    }
    
    func testGeneratedRegexWithStringLiteral() {
        let cucumber = Cucumber(withString: """
        Feature: Some terse yet descriptive text of what is desired
           Scenario: Some determinable business situation
             Given I login as "Dave"
        """)
        let actual = cucumber.generateUnimplementedStepDefinitions()
        let expected = """
        cucumber.Given("^I login as \\"(.*?)\\"$") { matches, _ in
            let stringOne = matches[1]
        }
        """
        XCTAssert(actual.contains(expected), "\"\(actual)\" does not contain \"\(expected)\"")
    }
    
    func testGeneratedRegexWithMultipleStringLiterals() {
        let cucumber = Cucumber(withString: """
        Feature: Some terse yet descriptive text of what is desired
           Scenario: Some determinable business situation
             Given I login as "Dave" with a password of "hello"
        """)
        let actual = cucumber.generateUnimplementedStepDefinitions()
        let expected = """
        cucumber.Given("^I login as \\"(.*?)\\" with a password of \\"(.*?)\\"$") { matches, _ in
            let stringOne = matches[1]
            let stringTwo = matches[2]
        }
        """
        XCTAssert(actual.contains(expected), "\"\(actual)\" does not contain \"\(expected)\"")
    }
    
//    func testGeneratedRegexWithMultipleIdenticalMatchesButDifferentKeywords() {
//        let cucumber = Cucumber(withString: """
//        Feature: Some terse yet descriptive text of what is desired
//           Scenario: Some determinable business situation
//             Given I login as "Dave"
//               And I login as "Dave"
//             When I login as "Dave"
//             Then I login as "Dave"
//        """)
//        let actual = cucumber.generateUnimplementedStepDefinitions()
//        let expected = """
//        cucumber.MatchAll("^I login as \\"(.*?)\\"$") { matches, _ in
//            let stringOne = matches[1]
//        }
//        """
//        XCTAssert(actual.contains(expected), "\"\(actual)\" does not contain \"\(expected)\"")
//    }
}
