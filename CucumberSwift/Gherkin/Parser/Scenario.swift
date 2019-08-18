//
//  Scenario.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
public class Scenario : NSObject, Taggable {
    public private(set)  var title = ""
    public private(set)  var tags = [String]()
    public internal(set) var steps = [Step]()
    public internal(set) var feature:Feature?
    
    init(with node:ScenarioNode, tags:[String], stepNodes:[StepNode]) {
        super.init()
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
        steps.forEach { $0.scenario = self }
    }
    
    init(with steps:[Step], title:String, tags:[String]) {
        super.init()
        self.steps = steps
        self.title = title
        self.tags = tags
        self.steps.forEach { [weak self] in $0.scenario = self }
    }
    
    public func containsTags(_ tags:[String]) -> Bool {
        return tags.contains { containsTag($0) }
    }

    
    func toJSON() -> [String:Any] {
        return [
            "id" : title.lowercased().replacingOccurrences(of: " ", with: "-"),
            "keyword" : "Scenario",
            "type" : "scenario",
            "name" : title,
            "description" : "",
            "steps" : []
        ]
    }
}
