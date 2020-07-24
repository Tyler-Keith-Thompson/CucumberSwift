//
//  FeatureDSL.swift
//  CucumberSwift
//
//  Created by thompsty on 7/23/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
public extension Feature {
    convenience init(_ title:String, tags:[String] = [], line:UInt = #line, column:UInt = #column, @ScenarioBuilder _ content: () -> [Scenario]) {
        self.init(with: content(), title: title, tags: tags, position: Lexer.Position(line: line, column: column))
        Cucumber.shared.features.append(self)
    }
    convenience init(_ title:String, tags:[String] = [], line:UInt = #line, column:UInt = #column, @ScenarioBuilder _ content: () -> Scenario) {
        self.init(with: [content()], title: title, tags: tags, position: Lexer.Position(line: line, column: column))
        Cucumber.shared.features.append(self)
    }
}
