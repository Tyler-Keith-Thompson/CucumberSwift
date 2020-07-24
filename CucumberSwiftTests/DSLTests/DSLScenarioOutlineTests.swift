//
//  DSLScenarioOutline.swift
//  CucumberSwiftTests
//
//  Created by thompsty on 7/23/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

class DSLScenarioOutlineTests: XCTestCase {
    func testScenarioOutlineCallsThroughForEveryRowInExamples() {
        ScenarioOutline("SomeTitle", headers: (first:String, last:String, balance:Double).self,
                        steps: { (first, last, balance) in
            Given(I: print(first))
        }, examples: {
            [
                (first: "John", last: "Doe", balance: 0),
                (first: "Jane", last: "Doe", balance: 10.50),
            ]
        })
    }
}
