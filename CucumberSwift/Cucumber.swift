//
//  Cucumber.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
public class Cucumber {
    var features = [Feature]()
    public var BeforeFeature  :((Feature)  -> Void) = {_ in }
    public var AfterFeature   :((Feature)  -> Void) = {_ in }
    public var BeforeScenario :((Scenario) -> Void) = {_ in }
    public var AfterScenario  :((Scenario) -> Void) = {_ in }
    public var BeforeStep     :((Step)     -> Void) = {_ in }
    public var AfterStep      :((Step)     -> Void) = {_ in }

    public init(withString string:String) {
        features = allSectionsFor(parentScope: .feature, inString:string)
            .flatMap { Feature(with: $0) }
    }
    
    public init(withDirectory directory:String, inBundle bundle:Bundle) {
        let enumerator:FileManager.DirectoryEnumerator? = FileManager.default.enumerator(at: bundle.bundleURL.appendingPathComponent(directory), includingPropertiesForKeys: nil)
        while let url = enumerator?.nextObject() as? URL {
            if let string = try? String(contentsOf: url, encoding: .utf8) {
                features.append(contentsOf: allSectionsFor(parentScope: .feature, inString:string)
                    .flatMap { Feature(with: $0) })
            }
        }
    }

    func allSectionsFor(parentScope:Scope, inString string:String) -> [[(scope: Scope, string: String)]] {
        var scope:Scope = parentScope
        var linesInScope = [(scope: Scope, string: String)]()
        var allSections = [[(scope: Scope, string: String)]]()
        for line in string.lines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if (trimmed.isEmpty || trimmed.starts(with: "#")) { continue }
            let lineScope = Scope.scopeFor(line: trimmed)
            if (lineScope.priority == parentScope.priority) {
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
    
    public func executeFeatures() {
        for feature in features {
            BeforeFeature(feature)
            for scenario in feature.scenarios {
                BeforeScenario(scenario)
                for step in scenario.steps {
                    BeforeStep(step)
                    step.execute?(step.match.matches(for: step.regex))
                    AfterStep(step)
                }
                AfterScenario(scenario)
            }
            AfterFeature(feature)
        }
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
            step.regex = regex
        }
    }
    
    public func Given(_ regex:String, callback:@escaping (([String]) -> Void)) {
        attachClosureToSteps(keyword: .given, regex: regex, callback:callback)
    }
    public func When(_ regex:String, callback:@escaping (([String]) -> Void)) {
        attachClosureToSteps(keyword: .when, regex: regex, callback:callback)
    }
    public func Then(_ regex:String, callback:@escaping (([String]) -> Void)) {
        attachClosureToSteps(keyword: .then, regex: regex, callback:callback)
    }
    public func And(_ regex:String, callback:@escaping (([String]) -> Void)) {
        attachClosureToSteps(keyword: .and, regex: regex, callback:callback)
    }
    public func Or(_ regex:String, callback:@escaping (([String]) -> Void)) {
        attachClosureToSteps(keyword: .or, regex: regex, callback:callback)
    }
    public func But(_ regex:String, callback:@escaping (([String]) -> Void)) {
        attachClosureToSteps(keyword: .but, regex: regex, callback:callback)
    }
    public func MatchAll(_ regex:String, callback:@escaping (([String]) -> Void)) {
        attachClosureToSteps(regex: regex, callback:callback)
    }
    
}
