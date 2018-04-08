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
    case scenario
    case step
    case unknown
    
    static func scopeFor(line:String) -> Scope {
        if (line.starts(with: "Feature")) {
            return .feature
        } else if (line.starts(with: "Scenario")) {
            return .scenario
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
}
