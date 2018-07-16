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
    
    func readIdentifierOrNumber() -> String? {
        var str:String? = nil
        while let char = currentChar, !char.isSpace {
            if (str == nil) { str = "" }
            str?.append(char)
            advanceIndex()
        }
        return str
    }
    
    func readUntilEndQuote() -> String {
        var str = ""
        while let char = currentChar, !char.isNewline, !char.isQuote {
            str.append(char)
            advanceIndex()
        }
        return str
    }
    
    func advanceToNextToken() -> Token? {
        while let char = currentChar, char.isSpace {
            advanceIndex()
            if char.isNewline {
                return .newLine
            }
        }
        guard let char = currentChar else {
            return nil
        }
        if !char.isSymbol {
            if let str = readIdentifierOrNumber() {
                switch str.lowercased() {
                default: return .identifier(str)
                }
            } else {
                advanceIndex()
                return .identifier(String(describing: char))
            }
        } else if char.isComment {
            advanceIndex()
            while let char = currentChar, !char.isNewline {
                advanceIndex()
            }
            advanceIndex()
            return advanceToNextToken()
        } else if char.isQuote {
            advanceIndex()
            let str = readUntilEndQuote()
            advanceIndex()
            return .string(str)
        } else if char.isTagMarker {
            advanceIndex()
            if let str = readIdentifierOrNumber() {
                return .tag(str)
            }
            return nil
        }
        return nil
    }
    
    func lex() -> [Token] {
        var toks = [Token]()
        while let tok = advanceToNextToken() {
            toks.append(tok)
        }
        return toks
    }
}
