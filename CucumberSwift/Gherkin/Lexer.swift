//
//  Lexer.swift
//  Kaleidoscope
//
//  Created by Tyler Thompson on 7/15/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
class Lexer : StringReader {
    var atLineStart = true
    var lastScope:Scope?
    var lastKeyword:Step.Keyword?
    var url:URL?
    
    init(_ str: String, uri:String) {
        url = URL(string: uri)
        super.init(str)
    }
    
    @discardableResult func readLineUntil(_ evaluation:((Character) -> Bool)) -> String {
        var str = ""
        while let char = currentChar, !char.isNewline, !evaluation(char) {
            str.append(char)
            advanceIndex()
        }
        return str
    }
    
    @discardableResult func stripSpaceIfNecessary() -> Bool {
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
    
    func advanceToNextToken() -> Token? {
        guard let char = currentChar else {
            return nil
        }
        if (char.isNewline) {
            atLineStart = true
            lastScope = nil
            lastKeyword = nil
            return advance(.newLine)
        } else if char.isComment {
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
        } else if char.isTagMarker {
            atLineStart = false
            return advance(.tag(readLineUntil({ !$0.isAlphanumeric })))
        } else if char.isTableCellDelimiter {
            atLineStart = false
            let tableCellContents = advance(readLineUntil({ $0.isTableCellDelimiter }).trimmingCharacters(in: .whitespaces))
            if (!tableCellContents.isEmpty) {
                return .tableCell(tableCellContents)
            }
            return advanceToNextToken()
        }
        if (atLineStart) {
            if (stripSpaceIfNecessary()) {
                return advanceToNextToken()
            }
            atLineStart = false
            let i = index
            let scope = Scope.scopeFor(str: readLineUntil{ $0.isScopeTerminator })
            if (scope != .unknown && !scope.isStep()) {
                lastScope = scope
                advance(stripSpaceIfNecessary())
                return .scope(scope)
            } else if case .step(let keyword) = scope {
                index = i
                readLineUntil { $0.isSpace }
                lastKeyword = keyword
                stripSpaceIfNecessary()
                return .keyword(keyword)
            } else {
                index = i
                return .description(readLineUntil{ $0.isNewline }.trimmingCharacters(in: .whitespaces))
            }
        } else if char.isHeaderOpen {
            let str = advance(readLineUntil{ $0.isHeaderClosed })
            return advance(.tableHeader(str))
        } else if let _ = lastScope {
            let title = readLineUntil{ $0.isHeaderOpen }
            if (title.isEmpty) { //hack to get around potential infinite loop
                return advance(advanceToNextToken())
            }
            return .title(title)
        } else if char.isQuote {
            let str = advance(readLineUntil{ $0.isQuote })
            return advance(.string(str))
        } else if char.isNumeric {
            return .integer(readLineUntil{ !$0.isNumeric })
        } else if let _ = lastKeyword {
            return .match(readLineUntil{ $0.isSymbol })
        } else {
            return advance(advanceToNextToken())
        }
    }
    
    func lex() -> [Token] {
        Scope.language = Language()!
        var toks = [Token]()
        while let tok = advanceToNextToken() {
            toks.append(tok)
        }
        if (!toks.contains(where: { !$0.isDescription() && $0 != .newLine })) {
            Gherkin.errors.append("File: \(url?.lastPathComponent ?? "") does not contain any valid gherkin")
        }
        return toks
    }
}
