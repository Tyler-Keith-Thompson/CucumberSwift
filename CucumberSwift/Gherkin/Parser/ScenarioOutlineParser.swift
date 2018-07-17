//
//  ScenarioOutlineParser.swift
//  CucumberSwift
//
//  Created by dev1 on 7/17/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
class ScenarioOutlineParser {
    static func parse(_ scenarioOutlineNode:ScenarioOutlineNode) -> [Scenario] {
        var scenarios = [Scenario]()
        var lines = groupTokensByLine(scenarioOutlineNode.tokens.filter{ $0.isTableCell() })
        var headerLookup:[String:Int] = [:]
        if let header = lines.first {
            for (i, token) in header.enumerated() {
                if case Token.tableCell(let headerText) = token {
                    headerLookup[headerText] = i
                }
            }
            lines.removeFirst()
        }
        return scenarios
    }
    
    private static func groupTokensByLine(_ tokens:[Token]) -> [[Token]] {
        var lines = [[Token]]()
        var line = [Token]()
        for token in tokens {
            if (token == .newLine) {
                lines.append(line)
                line.removeAll()
            } else {
                line.append(token)
            }
        }
        return lines
    }
}
