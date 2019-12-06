//
//  ScenarioOutlineParser.swift
//  CucumberSwift
//
//  Created by dev1 on 7/17/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
class ScenarioOutlineParser {
    static func parse(_ scenarioOutlineNode:AST.ScenarioOutlineNode, featureTags:[String], backgroundStepNodes:[AST.StepNode]) -> [Scenario] {
        var scenarios = [Scenario]()
        let titleLine = scenarioOutlineNode.tokens.groupedByLine().first
        var lines = scenarioOutlineNode.tokens.filter{ $0.isTableCell() || $0.isNewline() }.groupedByLine()
        var headerLookup:[String:Int] = [:]
        var tags = [String]()
        scenarioOutlineNode.tokens.forEach {
            if case Lexer.Token.tag(_, let tag) = $0 {
                tags.append(tag)
            }
        }
        if let header = lines.first {
            for (i, token) in header.enumerated() {
                if case Lexer.Token.tableCell(_, let headerText) = token {
                    headerLookup[headerText] = i
                }
            }
            lines.removeFirst()
        }
        let stepNodes = scenarioOutlineNode.children.compactMap { $0 as? AST.StepNode }
        for line in lines {
            var title = ""
            if let titleTokens = titleLine {
                for token in titleTokens {
                    if case Lexer.Token.tableHeader(_, let headerText) = token {
                        if let index = headerLookup[headerText],
                            index < line.count,
                            index >= 0,
                            case Lexer.Token.tableCell(_, let cellText) = line[index] {
                            title += cellText
                        }
                    } else if case Lexer.Token.title(_, let titleText) = token {
                        title += titleText
                    }
                }
            }
            var steps = backgroundStepNodes.map { Step(with: $0) }
            for stepNode in stepNodes {
                steps.append(getStepFromLine(line, lookup: headerLookup, stepNode: stepNode))
            }
            tags.append(contentsOf: featureTags)
            scenarios.append(Scenario(with: steps, title:title, tags: tags, position: line.first?.position ?? .start))
        }
        return scenarios
    }
    
    private static func getStepFromLine(_ line:[Lexer.Token], lookup:[String:Int], stepNode:AST.StepNode) -> Step {
        let node = AST.StepNode(node: stepNode)
        for (i, token) in node.tokens.enumerated() {
            if case Lexer.Token.tableHeader(_, let headerText) = token {
                if let index = lookup[headerText],
                    index < line.count,
                    index >= 0,
                    case Lexer.Token.tableCell(let pos, let cellText) = line[index] {
                    node.tokens[i] = .match(pos, cellText)
                }
            }
        }
        return Step(with: node)
    }
}
