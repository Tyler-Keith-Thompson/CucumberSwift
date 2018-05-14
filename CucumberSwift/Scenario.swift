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
    
    private func parseTags(inLines lines:[(scope: Scope, string: String)]) {
        for line in lines {
            if line.scope == .scenario && Scenario.isTag(line.string),
                let tagName = line.string.matches(for: "^@(\\w+)(?:\\s*)$").last {
                tags.append(tagName)
            }
        }
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
