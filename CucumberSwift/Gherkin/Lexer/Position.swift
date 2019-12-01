//
//  Position.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 11/29/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation

public extension Lexer {
    struct Position {
        static let start:Position = {
            return Position(line: 0, column: 0)
        }()
        internal var line:UInt
        internal var column:UInt
    }
}

extension Lexer.Position: Equatable {
    public static func == (lhs:Lexer.Position, rhs:Lexer.Position) -> Bool {
        return lhs.line == rhs.line
            && lhs.column == rhs.column
    }
}
