//
//  Scenario.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
public class Scenario : NSObject, Taggable, Positionable {
    public private(set)  var title = ""
    public private(set)  var tags = [String]()
    public internal(set) var steps = [Step]()
    public internal(set) var feature:Feature?
    public private(set)  var location:Lexer.Position
    public private(set)  var endLocation: Lexer.Position

    init(with node:ScenarioNode, tags:[String], stepNodes:[StepNode]) {
        location = node.tokens.first?.position ?? .start
        endLocation = .start
        super.init()
        self.tags = tags
        for token in node.tokens {
            if case Token.title(_, let t) = token {
                title = t
            } else if case Token.tag(_, let tag) = token {
                self.tags.append(tag)
            }
        }
        steps ?= node.children.compactMap { $0 as? StepNode }.map { Step(with: $0) }
        steps.insert(contentsOf: stepNodes.map { Step(with: $0) }, at: 0)
        steps.forEach { $0.scenario = self }
        endLocation ?= steps.last?.location
    }
    
    init(with steps:[Step], title:String, tags:[String], position:Lexer.Position) {
        location = position
        endLocation = position
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
