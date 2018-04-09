//
//  Scenario.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
public class Scenario {
    public private(set) var title = ""
    public private(set) var steps = [Step]()
    init(with lines:[(scope: Scope, string: String)]) {
        title ?= lines.first?.string.matches(for: "^(?:Scenario)(?:\\s*):?(?:\\s*)(.*?)$").last
        steps = lines.filter({ $0.scope == .step }).flatMap{ Step(with: $0) }
    }
    func toJSON() -> [String:Any] {
        return [
            "id" : title.lowercased().replacingOccurrences(of: " ", with: "-"),
            "keyword" : "Scenario",
            "type" : "scenario",
            "name" : title,
            "description" : "",
            "steps" : steps.map { $0.toJSON() }
        ]
    }
}
