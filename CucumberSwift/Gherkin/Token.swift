//
//  Token.swift
//  Kaleidoscope
//
//  Created by Tyler Thompson on 7/15/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation

enum Token: Equatable {
    case newLine
//    case integer(Int)
//    case double(Double)
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
//        case let (.integer(int1), .integer(int2)):
//            return int1 == int2
//        case let (.double(double1), .double(double2)):
//            return double1 == double2
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
}
