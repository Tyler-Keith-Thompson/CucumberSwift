//
//  Lexer.swift
//  Kaleidoscope
//
//  Created by Tyler Thompson on 7/15/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
class Lexer {
    let input: String
    var index: String.Index
    var linePosition:Int = 0
    var lastScope:Scope?
    var lastKeyword:Step.Keyword?
    
    init(input: String) {
        self.input = input
        self.index = input.startIndex
    }
    
    var currentChar: Character? {
        return index < input.endIndex ? input[index] : nil
    }
    
    func advanceIndex() {
        _ = input.formIndex(&index, offsetBy: 1, limitedBy: input.endIndex)
    }
    
    @discardableResult func readLineUntil(_ evaluation:((Character) -> Bool)) -> String {
        var str = ""
        while let char = currentChar, !char.isNewline, !evaluation(char) {
            str.append(char)
            advanceIndex()
        }
        return str
    }
    
    func advanceToNextToken() -> Token? {
        guard let char = currentChar else {
            return nil
        }
        if (char.isNewline) {
            advanceIndex()
            linePosition = 0
            lastScope = nil
            lastKeyword = nil
            return .newLine
        } else if char.isComment {
            advanceIndex()
            while let char = currentChar, !char.isNewline {
                advanceIndex()
            }
            advanceIndex()
            return advanceToNextToken()
        } else if char.isTagMarker {
            linePosition += 1
            advanceIndex()
            return .tag(readLineUntil({ !$0.isAlphanumeric }))
        } else if char.isTableCellDelimiter {
            linePosition += 1
            advanceIndex()
            let tableCellContents = readLineUntil({ $0.isTableCellDelimiter }).trimmingCharacters(in: .whitespaces)
            if (!tableCellContents.isEmpty) {
                return .tableCell(tableCellContents)
            }
            return advanceToNextToken()
        }
        if (linePosition == 0) {
            if (char.isSpace) {
                readLineUntil { !$0.isSpace }
                return advanceToNextToken()
            }
            linePosition += 1
            let i = index
            let scope = Scope.scopeFor(str: readLineUntil{ $0.isScopeTerminator }
                + String(describing: Character.scopeTerminator))
            if (scope != .unknown) {
                advanceIndex() //strip scope terminator
                lastScope = scope
                return .scope(scope)
            } else { index = i }
            if let keyword = Step.Keyword(rawValue: readLineUntil{ $0.isSpace }.lowercased()) {
                lastKeyword = keyword
                return .keyword(keyword)
            } else {
                index = i
                return .description(readLineUntil{ $0.isNewline }.trimmingCharacters(in: .whitespaces))
            }
        } else if let _ = lastScope {
            return .title(readLineUntil{ $0.isSymbol }.trimmingCharacters(in: .whitespaces))
        } else if char.isHeaderOpen {
            advanceIndex()
            let str = readLineUntil{ $0.isHeaderClosed }
            advanceIndex()
            return .tableHeader(str)
        } else if let _ = lastKeyword {
            return .match(readLineUntil{ $0.isSymbol }.trimmingCharacters(in: .whitespaces))
        } else {
            advanceIndex()
            return advanceToNextToken()
        }
//        else if char.isQuote {
//            advanceIndex()
//            let str = readUntil { !$0.isQuote }
//            advanceIndex()
//            return .string(str)
//        }
//        return nil
    }
    
    func lex() -> [Token] {
        var toks = [Token]()
        while let tok = advanceToNextToken() {
            toks.append(tok)
        }
        return toks
    }
}
