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
    
    init(with lines:[(scope: Scope, string: String)], tags:[String] = []) {
        self.tags.insert(contentsOf: tags, at: 0)
        parseTags(inLines: lines)
        let detagged = lines.filter{ !Scenario.isTag($0.string) }
        title ?= detagged.first?.string.matches(for: "^(?:Scenario)(?:\\s*):?(?:\\s*)(.*?)$").last
        var stepTag:String? = nil
        for line in lines.filter({ $0.scope == .step }) {
            if (Step.isTag(line.string)) {
                stepTag = line.string.matches(for: "^@(\\w+)(?:\\s*)$").last
                continue
            }
            let step = Step(with: line)
            step.tags.insert(contentsOf: self.tags, at: 0)
            if let tag = stepTag {
                step.tags.append(tag)
                stepTag = nil
            }
            steps.append(step)
        }
    }
    
    init (with lines:[[Token]], tags:[String] = []) {
        self.tags.insert(contentsOf: tags, at: 0)
        var scope:Scope = .scenario
        var stepLines = [[Token]]()
        for line in lines {
            guard let firstToken = line.first else { continue }
            if let firstIdentifier = line.firstIdentifier(),
                case Token.identifier(let id) = firstIdentifier {
                let s = Scope.scopeFor(str: id)
                if (s != .unknown) {
                    scope = s
                }
                var lineCopy = line
                if (s == .scenario) {
                    lineCopy.removeFirst()
                    title += lineCopy.stringAggregate
                }
                if (scope == .scenario && s == .unknown) {
                    description += lineCopy.stringAggregate
                    description += "\n"
                }
            } else if case Token.tag(let tag) = firstToken,
                scope == .scenario {
                self.tags.append(tag)
            }
            if (scope != .scenario) {
                stepLines.append(line)
            }
        }
        for line in stepLines {
            steps.append(Step(with: line))
        }
    }
    
    private func parseTags(inLines lines:[(scope: Scope, string: String)]) {
        for line in lines {
            if line.scope == .scenario && Scenario.isTag(line.string),
                let tagName = line.string.matches(for: "^@(\\w+)(?:\\s*)$").last {
                tags.append(tagName)
            }
        }
    }
    
    func containsTags(_ tags:[String]) -> Bool {
        if (!tags.filter{ containsTag($0) }.isEmpty) {
            return true
        }
        if (!steps.filter{ $0.containsTags(tags) }.isEmpty) {
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
