//
//  AST.swift
//  CucumberSwift
//
//  Created by dev1 on 7/17/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
class Node {
    var parent:Node?
    var tokens:[Token] = []
    var children:[Node] = []
    final func add(child:Node) {
        child.parent = self
        children.append(child)
    }
    init() { }
    init(node:Node) {
        parent   = node.parent
        tokens   = node.tokens
        children = node.children
    }
}
class FeatureNode: Node {}
class BackgroundNode: Node {}
class ScenarioNode: Node {}
class ScenarioOutlineNode: Node {}
class StepNode: Node {}

class AST {
    var featureNodes:[FeatureNode] = []
    init(_ tokens:[Token]) {
        var feature = FeatureNode()
        var tags = [Token]()
        var scenario:Node = ScenarioNode()
        var currentNode:Node?
        for token in tokens {
            if case Token.scope(_, let scope) = token {
                switch scope {
                case .feature:
                    feature = FeatureNode()
                    feature.tokens.append(contentsOf: tags)
                    tags.removeAll()
                    currentNode = feature
                    featureNodes.append(feature)
                case .background:
                    let background = BackgroundNode()
                    scenario = background
                    currentNode = background
                    feature.add(child: background)
                case .scenario:
                    scenario = ScenarioNode()
                    scenario.tokens.append(contentsOf: tags)
                    tags.removeAll()
                    currentNode = scenario
                    feature.add(child: scenario)
                case .scenarioOutline:
                    let outline = ScenarioOutlineNode()
                    scenario = outline
                    currentNode = scenario
                    scenario.tokens.append(contentsOf: tags)
                    tags.removeAll()
                    feature.add(child: scenario)
                case .examples:
                    currentNode = scenario
                default: currentNode?.tokens.append(token)
                }
            } else if case Token.keyword(_) = token {
                let step = StepNode()
                step.tokens.append(token)
                scenario.add(child: step)
                currentNode = step
            } else if case Token.tag(_) = token {
                tags.append(token)
            } else {
                currentNode?.tokens.append(token)
            }
        }
    }
}
