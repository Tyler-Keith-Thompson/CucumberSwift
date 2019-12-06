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
    static var standard:AST {
        return AST()
        .ruleFor(.feature, Rule.cleanAST
                                .then(.createNew)
                                .then(.appendTags))
        .ruleFor(.background, Rule.createNew
                                .then(.addToParent))
        .ruleFor(.scenario, Rule.createNew
                                .then(.appendTags)
                                .then(.addToParent))
        .ruleFor(.scenarioOutline, Rule.createNew
                                .then(.appendTags)
                                .then(.addToParent))
        .ruleFor(.examples, Rule.traverseToAppropriateDepth)
        .ruleFor(.keyword, Rule.createNew
                                .then(.addToParent)
                                .then(.addTokens))
    }
    
    private init(_ ruleLookup:[ASTToken:Rule] = [:]) {
        self.ruleLookup = ruleLookup
    }
    
    func parse(_ tokens:[Token]) -> [FeatureNode] {
        for token in tokens {
            passThroughTokens = false
            if case Token.tag(_) = token {
                tags.append(token)
            } else if let t = ASTToken(token),
                let rule = ruleLookup[t] {
                rule.execute(t, self)
                if (passThroughTokens) {
                    currentNode?.tokens.append(token)
                }
            } else {
                currentNode?.tokens.append(token)
            }
        }
        return featureNodes
    }
    var featureNodes:[FeatureNode] = []
    var ruleLookup:[ASTToken:Rule] = [:]
    var nodeLookup:[Int:Node] = [:]
    var tags = [Token]()
    var passThroughTokens = false

    var currentNode:Node?

    func ruleFor(_ token:ASTToken, _ rule:Rule) -> AST {
        var ruleLookup = self.ruleLookup
        ruleLookup[token] = rule
        return AST(ruleLookup)
    }
}

extension AST {
    class Rule {
        private(set) var execute:(ASTToken, AST) -> Void
        private init(_ closure: @escaping (ASTToken, AST) -> Void) {
            execute = closure
        }
        
        func then(_ rule:Rule) -> Rule {
            return Rule {
                self.execute($0, $1)
                rule.execute($0, $1)
            }
        }
        
        static let cleanAST = Rule { $1.nodeLookup = [:] }
        static let addTokens = Rule { $1.passThroughTokens = true }
        static let traverseToAppropriateDepth = Rule { $1.currentNode = $1.nodeLookup[$0.priority] }

        static let createNew = Rule {
            switch $0 {
                case .feature:
                    let feature = FeatureNode()
                    $1.nodeLookup[$0.priority] = feature
                    $1.featureNodes.append(feature)
                case .background: $1.nodeLookup[$0.priority] = BackgroundNode()
                case .scenario: $1.nodeLookup[$0.priority] = ScenarioNode()
                case .scenarioOutline: $1.nodeLookup[$0.priority] = ScenarioOutlineNode()
                case .keyword : $1.nodeLookup[$0.priority] = StepNode()
                default: return
            }
            $1.currentNode = $1.nodeLookup[$0.priority]
        }

        static let addToParent = Rule {
            guard let current = $1.currentNode else { return }
            $1.nodeLookup[$0.priority-1]?.add(child: current)
        }

        static let appendTags = Rule {
            $1.currentNode?.tokens.append(contentsOf: $1.tags)
            $1.tags.removeAll()
        }
    }
}

extension AST {
    enum ASTToken:Int {
        case feature
        case background
        case scenario
        case scenarioOutline
        case examples
        case keyword
        
        var priority:Int {
            switch self {
                case .feature: return 0
                case .background: return 1
                case .scenario: return 1
                case .scenarioOutline: return 1
                case .examples: return 1
                case .keyword: return 2
            }
        }
        
        init?(_ token:Token) {
            if case Token.keyword(_, _) = token {
                self = .keyword
            } else if case Token.scope(_, let scope) = token {
                switch (scope) {
                    case .feature: self = .feature
                    case .background: self = .background
                    case .scenario: self = .scenario
                    case .scenarioOutline: self = .scenarioOutline
                    case .examples: self = .examples
                    default: return nil
                }
            } else {
                return nil
            }
        }
    }
}
