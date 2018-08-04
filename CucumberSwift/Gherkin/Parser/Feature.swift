//
//  Feature.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
public class Feature : NSObject, Taggable {
    public private(set)  var title = ""
    public private(set)  var desc = ""
    public private(set)  var scenarios = [Scenario]()
    public private(set)  var uri:String = ""
    public internal(set) var tags = [String]()
    
    init(with node:FeatureNode, uri:String = "") {
        super.init()
        self.uri = uri
        for token in node.tokens {
            if case Token.title(let t) = token {
                title = t
            } else if case Token.description(let description) = token {
                desc += description + "\n"
            } else if case Token.tag(let tag) = token {
                self.tags.append(tag)
            }
        }
        let backgroundSteps:[StepNode] = node.children.filter { $0 is BackgroundNode }
                                        .map { $0 as! BackgroundNode }
                                        .flatMap { $0.children as! [StepNode] }
        node.children.forEach { (node) in
            if let sn = node as? ScenarioNode {
                scenarios.append(Scenario(with: sn, tags:tags, stepNodes: backgroundSteps))
            } else if let son = node as? ScenarioOutlineNode {
                let generatedScenarios = ScenarioOutlineParser.parse(son, featureTags: tags, backgroundStepNodes: backgroundSteps)
                scenarios.append(contentsOf: generatedScenarios)
            }
        }
        scenarios.forEach { $0.feature = self }
    }
    
    func containsTags(_ tags:[String]) -> Bool {
        if (tags.contains{ containsTag($0) }) {
            return true
        }
        if (scenarios.contains{ $0.containsTags(tags) }) {
            return true
        }
        return false
    }
    
    func toJSON() -> [String:Any] {
        return [
            "uri": uri,
            "id" : title.lowercased().replacingOccurrences(of: " ", with: "-"),
            "name" : title,
            "description" : desc,
            "keyword" : "Feature",
            "elements" : scenarios.map { $0.toJSON() }
        ]
    }
}
