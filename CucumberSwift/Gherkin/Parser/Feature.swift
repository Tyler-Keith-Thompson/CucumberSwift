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
    
    init (with node:FeatureNode) {
        for token in node.tokens {
            if case Token.title(let t) = token {
                title = t
            } else if case Token.description(let desc) = token {
                description += desc + "\n"
            } else if case Token.tag(let tag) = token {
                self.tags.append(tag)
            }
        }
        let backgroundSteps:[StepNode] = node.children.filter { $0 is BackgroundNode }
                                        .map { $0 as! BackgroundNode }
                                        .flatMap { $0.children as! [StepNode] }
        scenarios ?= node.children.filter { $0 is ScenarioNode }
                    .map { $0 as! ScenarioNode }
                    .compactMap{ Scenario(with: $0, tags:tags, stepNodes: backgroundSteps) }
        node.children.filter { $0 is ScenarioOutlineNode }
            .map { $0 as! ScenarioOutlineNode }.forEach { (son) in
                let generatedScenarios = ScenarioOutlineParser.parse(son, featureTags: tags)
                scenarios.append(contentsOf: generatedScenarios)
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
