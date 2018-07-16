//
//  Feature.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
public class Feature : Taggable {
    public private(set)  var title = ""
    public private(set)  var description = ""
    public private(set)  var scenarios = [Scenario]()
    public private(set)  var uri:String = ""
    public internal(set) var tags = [String]()
    
    init(with lines:[[Token]], uri:String? = nil) {
        self.uri ?= uri
        var scope:Scope = .feature
        var parentScope:Scope = .feature
        var scenarioLines = [[Token]]()
        var backgroundStepLines = [[Token]]()
        var foundIdentifierInScope = false
        for line in lines {
            guard let firstToken = line.first else { continue }
            if let firstIdentifier = line.firstIdentifier(),
            case Token.identifier(let id) = firstIdentifier {
                foundIdentifierInScope = true
                let s = Scope.scopeFor(str: id)
                if (s != .unknown) {
                    scope = s
                }
                if (s == .feature) {
                    title += line.removingScope().stringAggregate
                } else if (s == .scenario) {
                    parentScope = .scenario
                } else if (s == .background) {
                    parentScope = .background
                    continue
                }
                if (scope == .feature && s == .unknown) {
                    description += line.stringAggregate
                    description += "\n"
                }
            }
            if firstToken.isTag() &&
                scope == .feature &&
                !foundIdentifierInScope {
                for token in line {
                    if case Token.tag(let tag) = token {
                        self.tags.append(tag)
                    }
                }
            }
            if (firstToken.isTag() && foundIdentifierInScope) {
                scope = .scenario
                parentScope = .scenario
            }
            if (parentScope == .scenario) {
                scenarioLines.append(line)
            } else if (parentScope == .background) {
                backgroundStepLines.append(line)
            }
        }
        scenarios = scenarioLines.groupBy(.scenario).compactMap { Scenario(with: $0, tags:tags) }
        scenarios.forEach { (scenario) in
            scenario.steps.insert(contentsOf: backgroundStepLines.compactMap{ Step(with: $0, tags: tags)}, at: 0)
        }
    }
    
    func containsTags(_ tags:[String]) -> Bool {
        if (!tags.filter{ containsTag($0) }.isEmpty) {
            return true
        }
        if (!scenarios.filter{ $0.containsTags(tags) }.isEmpty) {
            return true
        }
        return false
    }
    
    func toJSON() -> [String:Any] {
        return [
            "uri": uri,
            "id" : title.lowercased().replacingOccurrences(of: " ", with: "-"),
            "name" : title,
            "description" : description,
            "keyword" : "Feature",
            "elements" : scenarios.map { $0.toJSON() }
        ]
    }
}
