//
//  ScenarioOutlineParser.swift
//  CucumberSwift
//
//  Created by dev1 on 7/17/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation

fileprivate extension Sequence where Element == Lexer.Token {
    func groupedByExample() -> [[Lexer.Token]] {
        var examples = [[Lexer.Token]]()
        var example = [Lexer.Token]()
        for token in self {
            if (token.isExampleScope() && !example.isEmpty) {
                examples.append(example)
                example.removeAll()
            } else {
                example.append(token)
            }
        }
        if (!example.isEmpty) {
            examples.append(example)
        }
        return examples
    }
}

class ScenarioOutlineParser {
    static func parse(_ scenarioOutlineNode:AST.ScenarioOutlineNode, featureTags:[String], backgroundStepNodes:[AST.StepNode]) -> [Scenario] {
        let tags = featureTags.appending(contentsOf: scenarioOutlineNode.tokens.compactMap {
            if case Lexer.Token.tag(_, let tag) = $0 {
                return tag
            }
            return nil
        })
        return getExamplesFrom(scenarioOutlineNode)
            .flatMap { parseExample(titleLine: scenarioOutlineNode
                                            .tokens
                                            .groupedByLine()
                                            .first,
                                    tokens: $0,
                                    outlineTags: tags,
                                    stepNodes: scenarioOutlineNode
                                        .children
                                        .compactMap { $0 as? AST.StepNode },
                                    backgroundStepNodes: backgroundStepNodes) }
    }
    
    static func getExamplesFrom(_ scenarioOutlineNode:AST.ScenarioOutlineNode) -> [[Lexer.Token]] {
        return scenarioOutlineNode.tokens.drop {
            !$0.isExampleScope()
        }.groupedByExample()
    }
    
    private static func parseExample(titleLine: [Lexer.Token]?, tokens: [Lexer.Token], outlineTags:[String], stepNodes:[AST.StepNode], backgroundStepNodes:[AST.StepNode]) -> [Scenario] {
        var scenarios = [Scenario]()
        var lines = tokens.filter{ $0.isTableCell() || $0.isNewline() }.groupedByLine()
        var headerLookup:[String:Int] = [:]
        let tags = outlineTags
        if let header = lines.first {
            for (i, token) in header.enumerated() {
                if case Lexer.Token.tableCell(_, let headerText) = token {
                    headerLookup[headerText] = i
                }
            }
            lines.removeFirst()
        }
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
