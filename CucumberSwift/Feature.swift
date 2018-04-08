//
//  Feature.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
public class Feature {
    public private(set) var title = ""
    public private(set) var description = ""
    public private(set) var scenarios = [Scenario]()
    
    init(with lines:[(scope: Scope, string: String)]) {
        title ?= lines.first?.string.matches(for: "^(?:Feature)(?:\\s*):?(?:\\s*)(.*?)$").last
        for (i, line) in lines.enumerated() {
            if (i == 0) { continue }
            if (line.scope == .feature) {
                description += "\(line.string)\n"
            }
        }
        scenarios = allSectionsFor(parentScope: .scenario,
                                   inLines: lines.filter { $0.scope != .feature })
                    .flatMap{ Scenario(with: $0) }
    }
    
    func allSectionsFor(parentScope:Scope, inLines lines:[(scope: Scope, string: String)]) -> [[(scope: Scope, string: String)]] {
        var linesInScope = [(scope: Scope, string: String)]()
        var allSections = [[(scope: Scope, string: String)]]()
        for line in lines {
            if (line.scope == parentScope) {
                if (!linesInScope.isEmpty) {
                    allSections.append(linesInScope)
                }
                linesInScope.removeAll()
            }
            linesInScope.append(line)
        }
        if (!linesInScope.isEmpty) {
            allSections.append(linesInScope)
        }
        return allSections
    }
}
