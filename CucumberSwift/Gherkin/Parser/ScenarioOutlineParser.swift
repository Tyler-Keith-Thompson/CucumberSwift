//
//  ScenarioOutlineParser.swift
//  CucumberSwift
//
//  Created by dev1 on 7/17/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
class ScenarioOutlineParser {
    static func parse(_ scenarioOutlineNode:ScenarioOutlineNode, featureTags:[String], backgroundStepNodes:[StepNode]) -> [Scenario] {
        var scenarios = [Scenario]()
        let titleLine = scenarioOutlineNode.tokens.groupedByLine().first
        var lines = scenarioOutlineNode.tokens.filter{ $0.isTableCell() || $0 == .newLine }.groupedByLine()
        var headerLookup:[String:Int] = [:]
        var tags = [String]()
        scenarioOutlineNode.tokens.forEach {
            if case Token.tag(let tag) = $0 {
                tags.append(tag)
            }
        }
        if let header = lines.first {
            for (i, token) in header.enumerated() {
                if case Token.tableCell(let headerText) = token {
                    headerLookup[headerText] = i
                }
            }
            lines.removeFirst()
        }
        let stepNodes = scenarioOutlineNode.children.filter { $0 is StepNode }
                        .map { $0 as! StepNode }
        for line in lines {
            var title = ""
            if let titleTokens = titleLine {
                for token in titleTokens {
                    if case Token.tableHeader(let headerText) = token {
                        if let index = headerLookup[headerText],
                            index < line.count,
                            index >= 0,
                            case Token.tableCell(let cellText) = line[index] {
                            title += cellText
                        }
                    } else if case Token.title(let titleText) = token {
                        title += titleText
                    }
                }
            }
            var steps = backgroundStepNodes.map { Step(with: $0) }
            for stepNode in stepNodes {
                steps.append(getStepFromLine(line, lookup: headerLookup, stepNode: stepNode))
            }
            scenarios.append(Scenario(with: steps, title:title, tags: tags))
        }
        return scenarios
    }
    
    private static func getStepFromLine(_ line:[Token], lookup:[String:Int], stepNode:StepNode) -> Step {
        let node = StepNode(node: stepNode)
        for (i, token) in node.tokens.enumerated() {
            if case Token.tableHeader(let headerText) = token {
                if let index = lookup[headerText],
                    index < line.count,
                    index >= 0,
                    case Token.tableCell(let cellText) = line[index] {
                    node.tokens[i] = .match(cellText)
                }
            }
        }
        return Step(with: node)
    }
}
