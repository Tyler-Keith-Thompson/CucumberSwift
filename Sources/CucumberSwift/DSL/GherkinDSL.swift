//
//  GherkinDSL.swift
//  CucumberSwift
//
//  Created by thompsty on 7/23/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
public protocol GherkinDSL {
    init()
    @discardableResult init(line: UInt, column: UInt, match: String?, handler: @escaping () -> Void)
}

private enum StepError: Error {
    case lineOutOfBounds
    case columnOutOfBounds
}

private func readStepName(lineNumber: UInt, column: UInt, filePath: StaticString) throws -> String {
    let fileContents = try String(contentsOfFile: String(filePath), encoding: .utf8)
    let lines = fileContents.components(separatedBy: .newlines)
    let lineIndex = Int(lineNumber-1)
    let columnIndex = Int(column-1)

    guard lineIndex+1 < lines.count else { throw StepError.lineOutOfBounds }

    var line = lines[lineIndex]

    guard columnIndex < line.count else { throw StepError.columnOutOfBounds }

    line.removeFirst(columnIndex)

    line += lines[lineIndex+1...lines.count-1].map { $0.trimmingCharacters(in: .whitespacesAndNewlines )}.joined()

    return readClosureNameFrom(line: line)
}

private func readClosureNameFrom(line: String) -> String {
    var matchedQuote = false

    // overly complex way of matching () to grab the step text
    // ignores strings and docstrings
    // any more complex and I need to pull in a way to look at the Swift AST
    return line.reduce((match:"", openCount: 0, closeCount: 0)) { (res, c) in
        let char = String(c)
        var (match, openCount, closeCount) = res
        if openCount > 0 && openCount == closeCount { return res }
        if char == "\"" {
            matchedQuote.toggle()
        }
        if char == "(" && !matchedQuote {
            openCount += 1
            guard openCount > 1 else {
                return (match: match,
                        openCount: openCount,
                        closeCount: closeCount)
            }
        }
        if (char == ")" && !matchedQuote) { closeCount += 1 }
        if openCount > 0 && openCount == closeCount {
            return (match: match,
                    openCount: openCount,
                    closeCount: closeCount)
        }
        return (match: match + char,
                openCount: openCount,
                closeCount: closeCount)
    }.match
}

public extension GherkinDSL {
    @discardableResult init(_ handler: @escaping @autoclosure () -> Void,
                            line: UInt = #line,
                            column: UInt = #column,
                            file: StaticString = #file,
                            function: StaticString = #function) {
        self.init(line: line,
                  column: column,
                  match: try? readStepName(lineNumber: line, column: column, filePath: file),
                  handler: handler)

    }

    @discardableResult init(I handler: @escaping @autoclosure () -> Void,
                            line: UInt = #line,
                            column: UInt = #column,
                            file: StaticString = #file,
                            function: StaticString = #function) {
        self.init(line: line,
                  column: column,
                  match: try? readStepName(lineNumber: line, column: column, filePath: file),
                  handler: handler)

    }

    @discardableResult init(it handler: @escaping @autoclosure () -> Void,
                            line: UInt = #line,
                            column: UInt = #column,
                            file: StaticString = #file,
                            function: StaticString = #function) {
        self.init(line: line,
                  column: column,
                  match: try? readStepName(lineNumber: line, column: column, filePath: file),
                  handler: handler)

    }

    @discardableResult init(my handler: @escaping @autoclosure () -> Void,
                            line: UInt = #line,
                            column: UInt = #column,
                            file: StaticString = #file,
                            function: StaticString = #function) {
        self.init(line: line,
                  column: column,
                  match: try? readStepName(lineNumber: line, column: column, filePath: file),
                  handler: handler)
    }

    @discardableResult init(some handler: @escaping @autoclosure () -> Void,
                            line: UInt = #line,
                            column: UInt = #column,
                            file: StaticString = #file,
                            function: StaticString = #function) {
        self.init(line: line,
                  column: column,
                  match: try? readStepName(lineNumber: line, column: column, filePath: file),
                  handler: handler)
    }

    @discardableResult init(a handler: @escaping @autoclosure () -> Void,
                            line: UInt = #line,
                            column: UInt = #column,
                            file: StaticString = #file,
                            function: StaticString = #function) {
        self.init(line: line,
                  column: column,
                  match: try? readStepName(lineNumber: line, column: column, filePath: file),
                  handler: handler)
    }

    @discardableResult init(the handler: @escaping @autoclosure () -> Void,
                            line: UInt = #line,
                            column: UInt = #column,
                            file: StaticString = #file,
                            function: StaticString = #function) {
        self.init(line: line,
                  column: column,
                  match: try? readStepName(lineNumber: line, column: column, filePath: file),
                  handler: handler)
    }
}
