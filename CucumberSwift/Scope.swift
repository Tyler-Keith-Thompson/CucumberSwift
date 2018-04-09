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
    case step
    case unknown
    
    static func scopeFor(line:String) -> Scope {
        if (line.starts(with: "Feature")) {
            return .feature
        } else if (line.starts(with: "Scenario")) {
            return .scenario
        } else if (line.starts(with: "Background")) {
            return .background
        } else if (line.starts(with: "Given")
            || line.starts(with: "When")
            || line.starts(with: "Then")
            || line.starts(with: "And")
            || line.starts(with: "Or")
            || line.starts(with: "But")) {
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
            case .step:
                return 2
            case .unknown:
                return -1
            }
        }
    }
}
