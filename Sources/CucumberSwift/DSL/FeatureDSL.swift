//
//  FeatureDSL.swift
//  CucumberSwift
//
//  Created by thompsty on 7/23/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
extension Feature {
    @discardableResult public convenience init(_ title: String,
                                               tags: [String] = [],
                                               line: UInt = #line,
                                               column: UInt = #column,
                                               @ScenarioBuilder _ content: () -> [ScenarioDSL]) {
        self.init(with: content().flatMap { $0.scenarios }, title: title, tags: tags, position: Lexer.Position(line: line, column: column))
        Cucumber.shared.features.append(self)
    }
    @discardableResult public convenience init(_ title: String,
                                               tags: [String] = [],
                                               line: UInt = #line,
                                               column: UInt = #column,
                                               @ScenarioBuilder _ content: () -> ScenarioDSL) {
        self.init(with: content().scenarios, title: title, tags: tags, position: Lexer.Position(line: line, column: column))
        Cucumber.shared.features.append(self)
    }
}
