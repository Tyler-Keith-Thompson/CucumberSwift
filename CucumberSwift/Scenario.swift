//
//  Scenario.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
class Scenario {
    var title = ""
    var steps = [Step]()
    init(with lines:[(scope: Scope, string: String)]) {
        title ?= lines.first?.string.matches(for: "^(?:Scenario)(?:\\s*):?(?:\\s*)(.*?)$").last
        steps = lines.filter({ $0.scope == .step }).flatMap{ Step(with: $0) }
    }
}
