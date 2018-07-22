//
//  Scope.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/8/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
enum Scope {
    static var language = Language()
    
    case feature
    case background
    case scenario
    case scenarioOutline
    case step
    case examples
    case unknown
    
    static func scopeFor(str:String) -> Scope {
        if (language.matchesFeature(str)) {
            return .feature
        } else if (language.matchesScenario(str)) {
            return .scenario
        } else if (language.matchesBackground(str)) {
            return .background
        } else if (language.matchesExamples(str)) {
            return .examples
        } else if (language.matchesScenarioOutline(str)) {
            return .scenarioOutline
        } else if (language.matchesGiven(str)
            || language.matchesWhen(str)
            || language.matchesThen(str)
            || language.matchesAnd(str)
            || language.matchesBut(str)) {
            return .step
        }
        return .unknown
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
            case .examples:
                return 1
            case .step:
                return 2
            case .unknown:
                return -1
            }
        }
    }
}
