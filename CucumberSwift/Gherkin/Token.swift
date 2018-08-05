//
//  Token.swift
//  Kaleidoscope
//
//  Created by Tyler Thompson on 7/15/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation

extension Sequence where Element == Token {
    func groupedByLine() -> [[Token]] {
        var lines = [[Token]]()
        var line = [Token]()
        for token in self {
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

enum Token: Equatable {
    case newLine
    case integer(String)
    case string(String)
    case match(String)
    case title(String)
    case description(String)
    case tag(String)
    case tableHeader(String)
    case tableCell(String)
    case scope(Scope)
    case keyword(Step.Keyword)
    
    static func ==(lhs: Token, rhs: Token) -> Bool {
        switch (lhs, rhs) {
        case (.newLine, .newLine):
            return true
        case let (.match(match1), .match(match2)):
            return match1 == match2
        case let (.title(title1), .title(title2)):
            return title1 == title2
        case let (.description(description1), .description(description2)):
            return description1 == description2
        case let (.tag(tag1), .tag(tag2)):
            return tag1 == tag2
        case let (.integer(num1), .integer(num2)):
            return num1 == num2
        case let (.string(string1), .string(string2)):
            return string1 == string2
        case let (.tableHeader(tableHeader1), .tableHeader(tableHeader2)):
            return tableHeader1 == tableHeader2
        case let (.tableCell(tableCell1), .tableCell(tableCell2)):
            return tableCell1 == tableCell2
        default:
            return false
        }
    }
    
    func isTableCell() -> Bool {
        if case .tableCell(_) = self {
            return true
        }
        return false
    }
    func isKeyword() -> Bool {
        if case .keyword(_) = self {
            return true
        }
        return false
    }
    func isTag() -> Bool {
        if case .tag(_) = self {
            return true
        }
        return false
    }
    func isString() -> Bool {
        if case .string(_) = self {
            return true
        }
        return false
    }
    func isInteger() -> Bool {
        if case .integer(_) = self {
            return true
        }
        return false
    }
}
