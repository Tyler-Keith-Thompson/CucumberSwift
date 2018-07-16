//
//  Scenario.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
public class Scenario : Taggable {
    public private(set)  var title = ""
    public private(set)  var description = ""
    public private(set)  var tags = [String]()
    public internal(set) var steps = [Step]()
    
    init (with lines:[[Token]], tags:[String] = []) {
        self.tags.insert(contentsOf: tags, at: 0)
        var scope:Scope = .scenario
        var stepLines = [[Token]]()
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
                if (s == .scenario) {
                    title += line.removingScope().stringAggregate
                }
                if (scope == .scenario && s == .unknown) {
                    description += line.stringAggregate
                    description += "\n"
                }
            }
            if firstToken.isTag() &&
                scope == .scenario &&
                !foundIdentifierInScope {
                for token in line {
                    if case Token.tag(let tag) = token {
                        self.tags.append(tag)
                    }
                }
            }
            if (scope != .scenario) {
                stepLines.append(line)
            }
        }
        for line in stepLines {
            steps.append(Step(with: line, tags: self.tags))
        }
    }
    
    func containsTags(_ tags:[String]) -> Bool {
        if (!tags.filter{ containsTag($0) }.isEmpty) {
            return true
        }
        return false
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
