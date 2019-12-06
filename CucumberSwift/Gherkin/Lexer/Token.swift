//
//  Token.swift
//  Kaleidoscope
//
//  Created by Tyler Thompson on 7/15/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation

extension Sequence where Element == Lexer.Token {
    func groupedByLine() -> [[Lexer.Token]] {
        var lines = [[Lexer.Token]]()
        var line = [Lexer.Token]()
        for token in self {
            if (token.isNewline() && !line.isEmpty) {
                lines.append(line)
                line.removeAll()
            } else if (!token.isNewline()) {
                line.append(token)
            }
        }
        if (!line.isEmpty) {
            lines.append(line)
        }
        return lines
    }
}

extension Lexer {
    enum Token: Equatable {
        case newLine(Lexer.Position)
        case integer(Lexer.Position, String)
        case string(Lexer.Position, String)
        case docString(Lexer.Position, DocString)
        case match(Lexer.Position, String)
        case title(Lexer.Position, String)
        case description(Lexer.Position, String)
        case tag(Lexer.Position, String)
        case tableHeader(Lexer.Position, String)
        case tableCell(Lexer.Position, String)
        case scope(Lexer.Position, Scope)
        case keyword(Lexer.Position, Step.Keyword)
        
        var position:Lexer.Position {
            switch self {
                case .newLine(let pos): return pos
                case .integer(let pos, _): return pos
                case .string(let pos, _): return pos
                case .docString(let pos, _): return pos
                case .match(let pos, _): return pos
                case .title(let pos, _): return pos
                case .description(let pos, _): return pos
                case .tag(let pos, _): return pos
                case .tableHeader(let pos, _): return pos
                case .tableCell(let pos, _): return pos
                case .scope(let pos, _): return pos
                case .keyword(let pos, _): return pos
            }
        }
        
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
            case let (.docString(_, string1), .docString(_, string2)):
                return string1.literal == string2.literal
            case let (.tableHeader(tableHeader1), .tableHeader(tableHeader2)):
                return tableHeader1 == tableHeader2
            case let (.tableCell(tableCell1), .tableCell(tableCell2)):
                return tableCell1 == tableCell2
            default:
                return false
            }
        }
        
        func isNewline() -> Bool {
            if case .newLine(_) = self {
                return true
            }
            return false
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
        func isDescription() -> Bool {
            if case .description(_) = self {
                return true
            }
            return false
        }
    }
}
