//
//  Feature.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
public class Feature : Taggable, Positionable {
    public private(set)  var title = ""
    public private(set)  var desc = ""
    public private(set)  var scenarios = [Scenario]()
    public private(set)  var uri:String = ""
    public internal(set) var tags = [String]()
    public private(set)  var location:Lexer.Position
    public private(set)  var endLocation: Lexer.Position
    
    init(with node:AST.FeatureNode, uri:String = "") {
        location = node.tokens.first?.position ?? .start
        endLocation = .start
        self.uri = uri
        for token in node.tokens {
            if case Lexer.Token.title(_, let t) = token {
                title = t
            } else if case Lexer.Token.description(_, let description) = token {
                desc += description + "\n"
            } else if case Lexer.Token.tag(_, let tag) = token {
                self.tags.append(tag)
            }
        }
        let backgroundSteps:[AST.StepNode] = node.children.compactMap { $0 as? AST.BackgroundNode }
                                        .flatMap { $0.children.compactMap { $0 as? AST.StepNode } }
        node.children.forEach { (node) in
            if let sn = node as? AST.ScenarioNode {
                scenarios.append(Scenario(with: sn, tags:tags, stepNodes: backgroundSteps))
            } else if let son = node as? AST.ScenarioOutlineNode {
                let generatedScenarios = ScenarioOutlineParser.parse(son, featureTags: tags, backgroundStepNodes: backgroundSteps)
                scenarios.append(contentsOf: generatedScenarios)
            } else if let rn = node as? AST.RuleNode {
                scenarios.append(contentsOf: RuleParser.parse(rn, featureTags: tags, backgroundStepNodes: backgroundSteps))
            }
        }
        scenarios.forEach { $0.feature = self }
        endLocation ?= scenarios.last?.endLocation
    }
    
    internal func addScenario(_ scenario:Scenario) {
        scenarios.append(scenario)
    }
    
    public func containsTags(_ tags:[String]) -> Bool {
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
            "elements" : []
        ]
    }
}
