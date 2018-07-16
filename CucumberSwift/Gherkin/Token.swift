//
//  Token.swift
//  Kaleidoscope
//
//  Created by Tyler Thompson on 7/15/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation

extension Array where Element == Token {
    var stringAggregate:String {
        return filter { $0.isIdentifier() || $0.isString() }
            .map {
                if case Token.identifier(let id) = $0 {
                    return id
                } else if case Token.string(let str) = $0 {
                    return "\"\(str)\""
                } else {
                    return ""
                }
            }
            .joined(separator: " ")
    }
    
    func firstIdentifier() -> Token? {
        return first(where: { (token) -> Bool in
            return token.isIdentifier()
        })
    }
    
    func removingScope() -> [Token] {
        var remaining = self
        if let firstID = firstIdentifier(),
            case Token.identifier(let id) = firstID,
            Scope.scopeFor(str: id) != .unknown,
            let scopeIndex = remaining.index(of: firstID) {
            if let colonIndex = index(scopeIndex, offsetBy: 1, limitedBy: endIndex),
                case Token.identifier(let colon) = self[colonIndex],
                colon == ":" {
                remaining.remove(at: colonIndex)
            }
            remaining.remove(at: scopeIndex)
        }
        return remaining
    }
}

extension Sequence where Element == [Token] {
    func groupBy(_ scope:Scope) -> [[[Token]]] {
        var allGroups = [[[Token]]]()
        var group = [[Token]]()
        for line in self {
            if let first = line.firstIdentifier(),
                case Token.identifier(let id) = first,
                Scope.scopeFor(str: id) == scope,
                group.count > 0,
                !group.containsOnlyTags() {
                allGroups.append(group)
                group.removeAll()
            } else {
                group.append(line)
            }
        }
        allGroups.append(group)
        return allGroups
    }
    func containsOnlyTags() -> Bool {
        for line in self {
            for token in line {
                if (!token.isTag()) {
                    return false
                }
            }
        }
        return true
    }
}

enum Token: Equatable {
    case newLine
//    case number(Double)
    case string(String)
    case identifier(String)
    case tag(String)
    
    static func ==(lhs: Token, rhs: Token) -> Bool {
        switch (lhs, rhs) {
        case (.newLine, .newLine):
            return true
        case let (.identifier(id1), .identifier(id2)):
            return id1 == id2
        case let (.tag(tag1), .tag(tag2)):
            return tag1 == tag2
        case let (.string(string1), .string(string2)):
            return string1 == string2
        default:
            return false
        }
    }
    
    func isIdentifier() -> Bool {
        if case .identifier(_) = self {
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
    func isTag() -> Bool {
        if case .tag(_) = self {
            return true
        }
        return false
    }
}
