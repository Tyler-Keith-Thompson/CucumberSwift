//
//  DocstringTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 7/22/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

class DocstringTests: XCTestCase {
    func testTableHeadersInsideDocStrings() {
        let _ = Cucumber(withString:"""
      Scenario Outline: the <one>
        Given the <two>:
          \"\"\"
                  <three>
          \"\"\"
        Given the <four>:
          | <five> |
            
            Examples:
              | one | two  | three | four   | five  |
              | un  | deux | trois | quatre | cinq  |
              | uno | dos  | tres  | quatro | cinco |
    """)
        
    }
}
