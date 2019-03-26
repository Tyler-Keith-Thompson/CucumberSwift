//
//  CommentTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 7/16/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift
class CommentTests: XCTestCase {
    func testInlineCommentsAreIgnored() {
        let cucumber = Cucumber(withString: """
    Feature: Some terse yet descriptive text of what is desired
       Scenario: Some determinable business situation
         Given some precondition #Snarky Dev Comment
    """)
        let firstScenario = cucumber.features.first?.scenarios.first
        let steps = firstScenario?.steps
        XCTAssertEqual(steps?.first?.keyword, .given)
        XCTAssertEqual(steps?.first?.match, "some precondition")
    }
    
    func testCommentedLinesAreIgnored() {
        let cucumber = Cucumber(withString: """
    Feature: Some terse yet descriptive text of what is desired
       Scenario: Some determinable business situation
         Given some precondition #Snarky Dev Comment
         #When something else happens
    """)
        let firstScenario = cucumber.features.first?.scenarios.first
        let steps = firstScenario?.steps
        XCTAssertEqual(steps?.first?.keyword, .given)
        XCTAssertEqual(steps?.first?.match, "some precondition")
        XCTAssertEqual(steps?.count, 1)
    }
    
    func testLanguageIsParsed() {
        let cucumber = Cucumber(withString: """
    #language:en

    Feature: Explicit language specification

      Scenario: minimalistic
        Given the minimalism
    """)
        XCTAssertEqual(cucumber.features.count, 1)
        XCTAssertEqual(cucumber.features.first?.title, "Explicit language specification")
        XCTAssertEqual(cucumber.features.first?.scenarios.first?.title, "minimalistic")
        XCTAssertEqual(cucumber.features.first?.scenarios.first?.steps.first?.keyword, .given)
        XCTAssertEqual(cucumber.features.first?.scenarios.first?.steps.first?.match, "the minimalism")
        XCTAssertEqual(Scope.language.given, "Given")
    }
    
    func testEmojiLanguageIsParsed() {
        let cucumber = Cucumber(withString: """
    # language: em
    📚: 🙈🙉🙊

      📕: 💃
        😐🎸
    """)
        XCTAssertEqual(cucumber.features.count, 1)
        XCTAssertEqual(cucumber.features.first?.title, "🙈🙉🙊")
        XCTAssertEqual(cucumber.features.first?.scenarios.first?.title, "💃")
//        XCTAssertEqual(cucumber.features.first?.scenarios.first?.steps.first?.keyword, .given)
//        XCTAssertEqual(cucumber.features.first?.scenarios.first?.steps.first?.match, "🎸")
        XCTAssertEqual(Scope.language.given, "😐")
    }
}
