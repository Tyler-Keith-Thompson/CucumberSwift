//
//  ErrorTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 10/6/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

class ErrorsTests : XCTestCase {
    override func setUp() {
        Cucumber.shared.features.removeAll()
        Gherkin.errors.removeAll()
    }
    func testNotGherkin() {
        Cucumber.shared.parseIntoFeatures("""
            Not Gherkin
        """, uri: "test.feature")
        XCTAssert(Gherkin.errors.contains("File: test.feature does not contain any valid gherkin"))
    }
    func testInvalidLanguage() {
        Cucumber.shared.parseIntoFeatures("""
            #language:no-such

            Feature: Minimal

              Scenario: minimalistic
                Given the minimalism
        """, uri: "failedLanguage.feature")
        XCTAssert(Gherkin.errors.contains("File: failedLanguage.feature declares an unsupported language"))
    }
    override func tearDown() {
        Gherkin.errors.removeAll()
    }
}
