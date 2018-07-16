//
//  CharacterExtensions.swift
//  Kaleidoscope
//
//  Created by Tyler Thompson on 7/15/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
extension Character {
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
        return isEscapeChar ||
               isComment ||
               isNewline ||
               isTagMarker ||
               isQuote
    }
    var isQuote: Bool {
        return self == "\""
    }
    var isTagMarker: Bool {
        return self == "@"
    }
    var isEscapeChar: Bool {
        return self == "\\"
    }
    var isComment: Bool {
        return self == "#"
    }
    var isNewline: Bool {
        return self == "\n"
    }
    var isWhitespace: Bool {
        return CharacterSet.whitespacesAndNewlines.contains(scalar)
    }
}
