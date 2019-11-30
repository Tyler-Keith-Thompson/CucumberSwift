//
//  Lexer.swift
//  Kaleidoscope
//
//  Created by Tyler Thompson on 7/15/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
public class Lexer : StringReader {
    internal var atLineStart = true
    internal var lastScope:Scope?
    internal var lastKeyword:Step.Keyword?
    internal var url:URL?
    
    internal init(_ str: String, uri:String) {
        url = URL(string: uri)
        super.init(str)
    }
    
    @discardableResult internal func readLineUntil(_ evaluation:((Character) -> Bool)) -> String {
        var str = ""
        while let char = currentChar, !char.isNewline, !evaluation(char) {
            str.append(char)
            advanceIndex()
        }
        return str
    }
    
    //table cells have weird rules I don't necessarily agree with...
    @discardableResult internal func readCellUntil(_ evaluation:((Character) -> Bool)) -> String {
        var str = ""
        while let char = currentChar, !char.isNewline {
            if char.isEscapeCharacter,
                let next = nextChar,
                next.isTableCellDelimiter || next == "n" || next.isEscapeCharacter {
                if (next == "n") {
                    str.append("\n")
                } else {
                    str.append(next)
                }
                advanceIndex()
                advanceIndex()
                continue
            }
            if (evaluation(char)) {
                break
            }
            str.append(char)
            advanceIndex()
        }
        return str
    }
    
    @discardableResult internal func stripSpaceIfNecessary() -> Bool {
        if let c = currentChar, c.isSpace {
            readLineUntil { !$0.isSpace }
            return true
        }
        return false
    }
    
    @discardableResult private func advance<T>(_ t:@autoclosure () -> T) -> T {
        advanceIndex()
        return t()
    }
    
    internal func advanceToNextToken() -> Token? {
        guard let char = currentChar else { return nil }
        defer {
            if (char.isNewline) {
                atLineStart = true
                lastScope = nil
                lastKeyword = nil
            } else if (char.isSymbol && previousChar?.isNewline != true) {
                atLineStart = false
            }
        }
        
        switch (char) {
        case .newLine: return advance(.newLine(position))
        case .comment: return readComment()
        case .tagMarker: return advance(.tag(position, readLineUntil({ !$0.isTagCharacter })))
        case .tableCellDelimiter:
            let tableCellContents = advance(readCellUntil({ $0.isTableCellDelimiter })
                                            .trimmingCharacters(in: .whitespaces))
            if (currentChar != Character.tableCellDelimiter) {
                return advanceToNextToken()
            }
            return .tableCell(position, tableCellContents)
        case _ where atLineStart: return readScope()
        case .tableHeaderOpen:
            let str = advance(readLineUntil{ $0.isHeaderClosed })
            return advance(.tableHeader(position, str))
        case _ where lastScope != nil:
            let title = readLineUntil{ $0.isHeaderOpen }
            if (title.isEmpty) { //hack to get around potential infinite loop
                return advance(advanceToNextToken())
            }
            return .title(position, title)
        case .quote:
            let str = advance(readLineUntil{ $0.isQuote })
            return advance(.string(position, str))
        case _ where char.isNumeric: return .integer(position, readLineUntil{ !$0.isNumeric })
        case _ where lastKeyword != nil: return .match(position, readLineUntil{ $0.isSymbol })
        default: return advance(advanceToNextToken())
        }
    }
    
    private func readComment() -> Token? {
        let str = advance(readLineUntil { _ in false })
        let matches = str.matches(for: "^(?:\\s*)language(?:\\s*):(?:\\s*)(.*?)(?:\\s*)$")
        if (!matches.isEmpty) {
            if let language = Language(matches[1]) {
                Scope.language = language
            } else {
                Gherkin.errors.append("File: \(url?.lastPathComponent ?? "") declares an unsupported language")
            }
        }
        return advance(advanceToNextToken())
    }
    
    //Feature, Scenario, Step etc...
    private func readScope() -> Token? {
        if (stripSpaceIfNecessary()) {
            return advanceToNextToken()
        }
        atLineStart = false
        let i = index
        let scope = Scope.scopeFor(str: readLineUntil{ $0.isScopeTerminator })
        if (scope != .unknown && !scope.isStep()) {
            lastScope = scope
            advance(stripSpaceIfNecessary())
            return .scope(position, scope)
        } else if case .step(let keyword) = scope {
            index = i
            readLineUntil { $0.isSpace }
            lastKeyword = keyword
            stripSpaceIfNecessary()
            return .keyword(position, keyword)
        } else {
            index = i
            return .description(position, readLineUntil{ $0.isNewline }.trimmingCharacters(in: .whitespaces))
        }
    }
    
    internal func lex() -> [Token] {
        Scope.language = Language()!
        var toks = [Token]()
        while let tok = advanceToNextToken() {
            toks.append(tok)
        }
        if (!toks.contains(where: { !$0.isDescription() && !$0.isNewline() })) {
            Gherkin.errors.append("File: \(url?.lastPathComponent ?? "") does not contain any valid gherkin")
        }
        return toks
    }
}
