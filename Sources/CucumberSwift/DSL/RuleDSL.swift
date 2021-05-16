//
//  RuleDSL.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 7/25/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation

public struct Rule: ScenarioDSL {
    public let scenarios: [Scenario]
    public init(_ title: String,
                tags: [String] = [],
                line: UInt = #line,
                column: UInt = #column,
                @ScenarioBuilder _ content: () -> [ScenarioDSL]) {
        scenarios = content().flatMap { $0.scenarios }
    }
    public init(_ title: String,
                tags: [String] = [],
                line: UInt = #line,
                column: UInt = #column,
                @ScenarioBuilder _ content: () -> ScenarioDSL) {
        scenarios = content().scenarios
    }
}
