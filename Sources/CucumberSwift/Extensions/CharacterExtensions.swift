//
//  CharacterExtensions.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 7/15/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation

extension CharacterSet {
    static let docStrings = CharacterSet(charactersIn: "\"`")
}

extension Character {
    static let tableHeaderOpen:Character = "<"
    static let tableHeaderClose:Character = ">"
    static let newLine:Character = "\n"
    static let scopeTerminator:Character = ":"
    static let quote:Character = "\""
    static let tagMarker:Character = "@"
    static let comment:Character = "#"
    static let tableCellDelimiter:Character = "|"
    static let decimal:Character = "."
    static let escapeCharacter:Character = "\\"
    
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
    var isTagCharacter: Bool {
        return !self.isSpace
            && !isComment
            && !isNewline
            && !isTagMarker
            && !isQuote
            && !isTableCellDelimiter
            && !isHeaderToken
    }
    var isNumeric: Bool {
        return isnumber(value) != 0
    }
    var isDecimal: Bool {
        return self == Character.decimal
    }
    var isSymbol: Bool {
        return isComment ||
            isNewline ||
            isTagMarker ||
            isQuote ||
            isNumeric ||
            isTableCellDelimiter ||
            isHeaderToken
    }
    var isHeaderToken: Bool {
        return isHeaderOpen || isHeaderClosed
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
    var isScopeTerminator: Bool {
        return self == Character.scopeTerminator
    }
    var isTableCellDelimiter: Bool {
        return self == Character.tableCellDelimiter
    }
    var isEscapeCharacter: Bool {
        return self == Character.escapeCharacter
    }
    var isDocStringLiteral: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return CharacterSet.docStrings.contains(scalar)
    }
}
