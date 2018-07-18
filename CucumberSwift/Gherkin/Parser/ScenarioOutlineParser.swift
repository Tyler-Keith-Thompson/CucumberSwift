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
        var lines = groupTokensByLine(scenarioOutlineNode.tokens.filter{ $0.isTableCell() || $0 == .newLine })
        var headerLookup:[String:Int] = [:]
        var title = ""
        var tags = [String]()
        for token in scenarioOutlineNode.tokens {
            if case Token.title(let t) = token {
                title = t
            } else if case Token.tag(let tag) = token {
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
            var steps = backgroundStepNodes.map { Step(with: $0) }
            for stepNode in stepNodes {
                if let step = getStepFromLine(line, lookup: headerLookup, node: stepNode) {
                    steps.append(step)
                }
            }
            scenarios.append(Scenario(with: steps, title:title, description:description, tags: tags))
        }
        return scenarios
    }
    
    private static func getStepFromLine(_ line:[Token], lookup:[String:Int], node:StepNode) -> Step? {
        if let keywordToken = node.tokens.first(where: { (token) -> Bool in
            return token.isKeyword()
        }) {
            var match = ""
            for token in node.tokens {
                if case Token.tableHeader(let headerText) = token {
                    if let index = lookup[headerText],
                        index < line.count,
                        index >= 0,
                        case Token.tableCell(let cellText) = line[index] {
                        match += " " + cellText + " "
                    }
                } else if case Token.match(let m) = token {
                    match += m
                }
            }
            if case Token.keyword(let keyword) = keywordToken {
                return Step(with: keyword, match: match.trimmingCharacters(in: .whitespaces))
            }
        }
        return nil
    }
    
    private static func groupTokensByLine(_ tokens:[Token]) -> [[Token]] {
        var lines = [[Token]]()
        var line = [Token]()
        for token in tokens {
            if (token == .newLine && !line.isEmpty) {
                lines.append(line)
                line.removeAll()
            } else if (token != .newLine) {
                line.append(token)
            }
        }
        if (!line.isEmpty) {
            lines.append(line)
        }
        return lines
    }
}
