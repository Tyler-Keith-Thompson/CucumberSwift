//
//  StringReader.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/5/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
public class StringReader {
    let input: String
    public var index: String.Index
    public var position: Lexer.Position {
        return Lexer.Position(line: line, column: column)
    }
    
    private var line:UInt = 0
    private var lastLinePosition:UInt = 0 {
        willSet {
            holdLinePosition = lastLinePosition
        }
    }
    private var holdLinePosition:UInt = 0
    private var column:UInt = 0
    
    init(_ str: String) {
        input = str
        index = input.startIndex
    }
    
    public var currentChar: Character? {
        return (index < input.endIndex && index >= input.startIndex) ? input[index] : nil
    }
    
    public var nextChar: Character? {
        if let i = input.index(index, offsetBy: 1, limitedBy: input.endIndex) {
            guard i != input.endIndex else { return input.last }
            return input[i]
        }
        return nil
    }
    
    public var previousChar: Character? {
        if let i = input.index(index, offsetBy: -1, limitedBy: input.startIndex) {
            return input[i]
        }
        return nil
    }
    
    func advanceIndex() {
        _ = input.formIndex(&index, offsetBy: 1, limitedBy: input.endIndex)
        if (index < input.endIndex && input[index].isNewline) {
            line += 1
            column = 0
            lastLinePosition = holdLinePosition
        } else {
            column += 1
        }
    }
    
    func reduceIndex() {
        _ = input.formIndex(&index, offsetBy: -1, limitedBy: input.startIndex)
        if (input[index].isNewline) {
            line -= 1
            let lineIndex:UInt = {
                let substr = input.prefix(upTo: index)
                guard let lineIndex = substr.lastIndex(of: Character.newLine) else {
                    return 0
                }
                return UInt(input.distance(from: input.startIndex, to: lineIndex))
            }()
            lastLinePosition = lineIndex
            column = UInt(input.distance(from: input.startIndex, to: index)) - lastLinePosition
        } else {
            column -= 1
        }
    }
    
    @discardableResult public func lookAheadUntil(_ evaluation:((Character) -> Bool)) -> String {
        var str = ""
        var index = self.index
        let currentCharacter = {
            return (index < self.input.endIndex && index >= self.input.startIndex) ? self.input[index] : nil
        }
        while let char = currentCharacter(), !evaluation(char) {
            str.append(char)
            _ = input.formIndex(&index, offsetBy: 1, limitedBy: input.endIndex)
        }
        return str
    }
    
    @discardableResult public func lookBehindUntil(_ evaluation:((Character) -> Bool)) -> String {
        var str = ""
        var index = self.index
        let previousChar:() -> Character? = {
            if let i = self.input.index(index, offsetBy: -1, limitedBy: self.input.startIndex) {
                return self.input[i]
            }
            return nil
        }
        while let char = previousChar(), !evaluation(char) {
            str.append(char)
            _ = input.formIndex(&index, offsetBy: -1, limitedBy: input.startIndex)
        }
        return String(str.reversed())
    }
    
    @discardableResult public func readUntil(_ evaluation:((Character) -> Bool)) -> String {
        var str = ""
        while let char = currentChar, !evaluation(char) {
            str.append(char)
            advanceIndex()
        }
        return str
    }
    
    @discardableResult public func readBehindUntil(_ evaluation:((Character) -> Bool)) -> String {
        var str = ""
        while let char = previousChar, !evaluation(char) {
            str.append(char)
            reduceIndex()
        }
        return str
    }
}
