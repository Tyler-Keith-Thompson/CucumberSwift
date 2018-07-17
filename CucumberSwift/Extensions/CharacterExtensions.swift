//
//  CharacterExtensions.swift
//  Kaleidoscope
//
//  Created by Tyler Thompson on 7/15/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
extension Character {
    static let tableHeaderOpen:Character = "<"
    static let tableHeaderClose:Character = ">"
    static let newLine:Character = "\n"
    static let scopeTerminator:Character = ":"
    static let quote:Character = "\""
    static let tagMarker:Character = "@"
    static let comment:Character = "#"
    var value: Int32 {
        return Int32(scalar.value)
    }
    var scalar: UnicodeScalar {
        return String(self).unicodeScalars.first!
    }
    var isSpace: Bool {
        return isspace(value) != 0
    }
    var isAlphanumeric: Bool {
        return isalnum(value) != 0
    }
    var isSymbol: Bool {
        return isComment ||
            isNewline ||
            isTagMarker ||
//            isQuote ||
            isHeaderToken
    }
    var isHeaderToken: Bool {
        return self == Character.tableHeaderOpen || self == Character.tableHeaderClose
    }
    var isHeaderOpen: Bool {
        return self == Character.tableHeaderOpen
    }
    var isHeaderClosed: Bool {
        return self == Character.tableHeaderClose
    }
    var isQuote: Bool {
        return self == Character.quote
    }
    var isTagMarker: Bool {
        return self == Character.tagMarker
    }
    var isComment: Bool {
        return self == Character.comment
    }
    var isNewline: Bool {
        return self == Character.newLine
    }
    var isWhitespace: Bool {
        return CharacterSet.whitespacesAndNewlines.contains(scalar)
    }
    var isScopeTerminator: Bool {
        return self == Character.scopeTerminator
    }
}
