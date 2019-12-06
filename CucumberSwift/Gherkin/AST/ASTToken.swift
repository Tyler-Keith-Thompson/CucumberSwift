//
//  ASTToken.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 12/6/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
extension AST {
    enum Token:Int {
        case feature
        case rule
        case background
        case scenario
        case scenarioOutline
        case examples
        case step
        
        var priority:UInt {
            switch self {
                case .feature: return 0
                case .rule: return 1
                case .background: return 2
                case .scenario: return 2
                case .scenarioOutline: return 2
                case .examples: return 2
                case .step: return 3
            }
        }
        
        init?(_ token:Lexer.Token) {
            if case Lexer.Token.keyword(_, _) = token {
                self = .step
            } else if case Lexer.Token.scope(_, let scope) = token {
                switch (scope) {
                    case .feature: self = .feature
                    case .rule: self = .rule
                    case .background: self = .background
                    case .scenario: self = .scenario
                    case .scenarioOutline: self = .scenarioOutline
                    case .examples: self = .examples
                    default: return nil
                }
            } else {
                return nil
            }
        }
    }
}
