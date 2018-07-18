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
    
    init(with node:ScenarioNode, tags:[String], stepNodes:[StepNode]) {
        self.tags = tags
        for token in node.tokens {
            if case Token.title(let t) = token {
                title = t
            } else if case Token.tag(let tag) = token {
                self.tags.append(tag)
            }
        }
        steps ?= ((node.children as? [StepNode])?.compactMap{ Step(with: $0) })
        steps.insert(contentsOf: stepNodes.map { Step(with: $0) }, at: 0)
    }
    
    init(with steps:[Step], title:String, tags:[String]) {
        self.steps = steps
        self.title = title
        self.tags = tags
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
