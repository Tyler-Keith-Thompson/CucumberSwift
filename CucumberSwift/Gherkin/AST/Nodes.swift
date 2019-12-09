//
//  Nodes.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 12/6/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
extension AST {
    class Node {
        var parent:Node?
        var tokens:[Lexer.Token] = []
        var children:[Node] = []
        final func add(child:Node) {
            child.parent = self
            children.append(child)
        }
        init(node:Node? = nil) {
            parent   ?= node?.parent
            tokens   ?= node?.tokens
            children ?= node?.children
        }
    }

    class FeatureNode: Node {
        //this class is merely a way to hold onto hierarchy, it's very useful in the parser
    }
    class RuleNode: Node {
        //this class is merely a way to hold onto hierarchy, it's very useful in the parser
    }
    class BackgroundNode: Node {
        //this class is merely a way to hold onto hierarchy, it's very useful in the parser
    }
    class ScenarioNode: Node {
        //this class is merely a way to hold onto hierarchy, it's very useful in the parser
    }
    class ScenarioOutlineNode: Node {
        //this class is merely a way to hold onto hierarchy, it's very useful in the parser
    }
    class StepNode: Node {
        //this class is merely a way to hold onto hierarchy, it's very useful in the parser
    }
}
