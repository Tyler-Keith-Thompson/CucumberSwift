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
        func printAStatement() {
            print("Printed")
        }
        Given(I: printAStatement())
    }
}
