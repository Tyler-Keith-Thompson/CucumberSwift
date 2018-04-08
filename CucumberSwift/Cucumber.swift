//
//  Cucumber.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
class Cucumber {
    var features = [Feature]()
    
    init(with file:String) {
        features = allSectionsFor(parentScope: .feature, inString:file)
            .flatMap { Feature(with: $0) }
    }
    
    func allSectionsFor(parentScope:Scope, inString string:String) -> [[(scope: Scope, string: String)]] {
        var scope:Scope = parentScope
        var linesInScope = [(scope: Scope, string: String)]()
        var allSections = [[(scope: Scope, string: String)]]()
        for line in string.lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if (trimmed.isEmpty || trimmed.starts(with: "#")) { continue }
            let lineScope = Scope.scopeFor(line: trimmed)
            if (lineScope == parentScope) {
                allSections.append(linesInScope)
                linesInScope.removeAll()
            }
            if (lineScope != .unknown && lineScope != scope) {
                scope = lineScope
            }
            linesInScope.append((scope: scope, string: trimmed))
        }
        allSections.append(linesInScope)
        return allSections.filter{ !$0.isEmpty }
    }
    
    func attachClosureToSteps(keyword:Step.Keyword? = nil, regex:String, callback:@escaping (([String]) -> Void)) {
        features
        .flatMap { $0.scenarios.flatMap { $0.steps } }
        .filter { (step) -> Bool in
            if (keyword == nil || keyword == step.keyword) {
                return !step.match.matches(for: regex).isEmpty
            }
            return false
        }.forEach { (step) in
            step.execute = callback
        }
    }
    
    func Given(_ regex:String, callback:@escaping (([String]) -> Void)) {
        attachClosureToSteps(keyword: .given, regex: regex, callback:callback)
    }
    func When(_ regex:String, callback:@escaping (([String]) -> Void)) {
        attachClosureToSteps(keyword: .when, regex: regex, callback:callback)
    }
    func Then(_ regex:String, callback:@escaping (([String]) -> Void)) {
        attachClosureToSteps(keyword: .then, regex: regex, callback:callback)
    }
    func And(_ regex:String, callback:@escaping (([String]) -> Void)) {
        attachClosureToSteps(keyword: .and, regex: regex, callback:callback)
    }
    func Or(_ regex:String, callback:@escaping (([String]) -> Void)) {
        attachClosureToSteps(keyword: .or, regex: regex, callback:callback)
    }
    func But(_ regex:String, callback:@escaping (([String]) -> Void)) {
        attachClosureToSteps(keyword: .but, regex: regex, callback:callback)
    }
    func MatchAll(_ regex:String, callback:@escaping (([String]) -> Void)) {
        attachClosureToSteps(regex: regex, callback:callback)
    }
}
