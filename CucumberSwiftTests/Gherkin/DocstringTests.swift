//
//  DocstringTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 7/22/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

class DocstringTests: XCTestCase {
    func testSimpleDocString() {
        let cucumber = Cucumber(withString:
            """
            Feature: DocString variations

            Scenario: minimalistic
              Given a simple DocString
                \"""
                first line (no indent)
                  second line (indented with two spaces)

                third line was empty
                \"""
            """)
        let firstStep = cucumber.features.first?.scenarios.first?.steps.first
        XCTAssertEqual(firstStep?.docString?.literal, """
        first line (no indent)
          second line (indented with two spaces)

        third line was empty
        """)
    }
    
    func testDocStringWithContentType() {
        let cucumber = Cucumber(withString:
            """
            Feature: DocString variations

            Scenario: minimalistic
              Given a DocString with content type
                \"""xml
                <foo>
                  <bar />
                </foo>
                \"""
            """)
        let firstStep = cucumber.features.first?.scenarios.first?.steps.first
        XCTAssertEqual(firstStep?.docString?.literal, """
        <foo>
          <bar />
        </foo>
        """)
        XCTAssertEqual(firstStep?.docString?.contentType, "xml")
    }
    
    func testDocStringWithWrongIndentation() {
        let cucumber = Cucumber(withString:
            """
            Feature: DocString variations

            Scenario: minimalistic
              Given a DocString with wrong indentation
                \"""
              wrongly indented line
                \"""
            """)
        let firstStep = cucumber.features.first?.scenarios.first?.steps.first
        XCTAssertEqual(firstStep?.docString?.literal, """
        wrongly indented line
        """)
    }
    
    func testDocStringWithAlternativeIndicator() {
        let cucumber = Cucumber(withString:
            """
            Feature: DocString variations

            Scenario: minimalistic
              Given a DocString with alternative separator
                ```
                first line
                second line
                ```
            """)
        let firstStep = cucumber.features.first?.scenarios.first?.steps.first
        XCTAssertEqual(firstStep?.docString?.literal, """
        first line
        second line
        """)
    }

    func testDocStringWithNormalSeparatorInside() {
        let cucumber = Cucumber(withString:
            """
            Feature: DocString variations

            Scenario: minimalistic
              Given a DocString with normal separator inside
                ```
                first line
                \"""
                third line
                ```
            """)
        let firstStep = cucumber.features.first?.scenarios.first?.steps.first
        XCTAssertEqual(firstStep?.docString?.literal, """
        first line
        \"""
        third line
        """)
    }
    
    func testDocStringWithAlternativeSeparatorInside() {
        let cucumber = Cucumber(withString:
            """
            Feature: DocString variations

            Scenario: minimalistic
              Given a DocString with alternative separator inside
                \"""
                first line
                ```
                third line
                \"""
            """)
        let firstStep = cucumber.features.first?.scenarios.first?.steps.first
        XCTAssertEqual(firstStep?.docString?.literal, """
        first line
        ```
        third line
        """)
    }
    
    func testDocStringWithEscapedSequenceInside() {
        let cucumber = Cucumber(withString:
            """
            Feature: DocString variations

            Scenario: minimalistic
                Given a DocString with escaped separator inside
                  \"""
                  first line
                  \\"\\"\\"
                  third line
                  \"""
            """)
        let firstStep = cucumber.features.first?.scenarios.first?.steps.first
        XCTAssertEqual(firstStep?.docString?.literal, """
        first line
        \\"\\"\\"
        third line
        """)
    }
}
