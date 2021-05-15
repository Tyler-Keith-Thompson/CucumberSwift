//
//  PositionTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 7/25/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

class PositionTests: XCTestCase {
    func testPositionEquatability() {
        XCTAssertEqual(Lexer.Position(line: 10, column: 5), Lexer.Position(line: 10, column: 5))
        XCTAssertNotEqual(Lexer.Position(line: 9, column: 5), Lexer.Position(line: 10, column: 5))
        XCTAssertNotEqual(Lexer.Position(line: 10, column: 3), Lexer.Position(line: 10, column: 5))
    }
}
