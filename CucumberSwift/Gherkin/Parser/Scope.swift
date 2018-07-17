//
//  Scope.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/8/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
enum Scope {
    case feature
    case background
    case scenario
    case scenarioOutline
    case step
    case example
    case unknown
    
    static func scopeFor(str:String) -> Scope {
        switch str.lowercased() {
        case "feature:": return .feature
        case "scenario:": return .scenario
        case "background:": return .background
        case "example:": return .example
        case "scenario outline:": return .scenarioOutline
        case "given": return .step
        case "when": return .step
        case "then": return .step
        case "and": return .step
        case "or": return .step
        case "but": return .step
        default: return .unknown
        }
    }
    
    var priority:Int {
        get {
            switch self {
            case .feature:
                return 0
            case .background:
                return 1
            case .scenario:
                return 1
            case .scenarioOutline:
                return 1
            case .example:
                return 1
            case .step:
                return 2
            case .unknown:
                return -1
            }
        }
    }
}
