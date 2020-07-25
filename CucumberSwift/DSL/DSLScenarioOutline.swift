//
//  DSLScenarioOutline.swift
//  CucumberSwift
//
//  Created by thompsty on 7/23/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation

public struct ScenarioOutline: ScenarioDSL {
    public var scenarios: [Scenario] = []
    
    @discardableResult public init<T>(_ title:String, tags:[String] = [], headers: T.Type,
                                      line:UInt = #line, column:UInt = #column,
                                      @StepBuilder steps: (T) -> [DSLStep], examples: () -> [T]) {
        scenarios = examples().map {
            Scenario(with: steps($0),
                     title: title,
                     tags: tags,
                     position: Lexer.Position(line: line, column: column))
        }
    }
    
    @discardableResult public init<T>(_ title:String, tags:[String] = [], headers: T.Type,
                                      line:UInt = #line, column:UInt = #column,
                                      @StepBuilder steps: (T) -> DSLStep, examples: () -> [T]) {
        scenarios = examples().map {
            Scenario(with: [steps($0)],
                     title: title,
                     tags: tags,
                     position: Lexer.Position(line: line, column: column))
        }
    }
    
    @discardableResult public init<T>(_ title:(T) -> String, tags:[String] = [], headers: T.Type,
                                      line:UInt = #line, column:UInt = #column,
                                      @StepBuilder steps: (T) -> [DSLStep], examples: () -> [T]) {
        scenarios = examples().map {
            Scenario(with: steps($0),
                     title: title($0),
                     tags: tags,
                     position: Lexer.Position(line: line, column: column))
        }
    }
    
    @discardableResult public init<T>(_ title:(T) -> String, tags:[String] = [], headers: T.Type,
                                      line:UInt = #line, column:UInt = #column,
                                      @StepBuilder steps: (T) -> DSLStep, examples: () -> [T]) {
        scenarios = examples().map {
            Scenario(with: [steps($0)],
                     title: title($0),
                     tags: tags,
                     position: Lexer.Position(line: line, column: column))
        }
    }

}
