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
    
    init(_ str: String) {
        input = str
        index = input.startIndex
    }
    
    public var currentChar: Character? {
        return (index < input.endIndex && index >= input.startIndex) ? input[index] : nil
    }
    
    public var nextChar: Character? {
        if let i = input.index(index, offsetBy: 1, limitedBy: input.endIndex) {
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
    }
    
    func reduceIndex() {
        _ = input.formIndex(&index, offsetBy: -1, limitedBy: input.startIndex)
    }
    
    @discardableResult public func lookAheadUntil(_ evaluation:((Character) -> Bool)) -> String {
        let i = index
        let str = readUntil(evaluation)
        index = i
        return str
    }
    
    @discardableResult public func lookBehindUntil(_ evaluation:((Character) -> Bool)) -> String {
        let i = index
        let str = readBehindUntil(evaluation)
        index = i
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
