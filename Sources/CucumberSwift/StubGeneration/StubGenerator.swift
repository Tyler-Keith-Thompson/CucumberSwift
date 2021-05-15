//
//  StubGenerator.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/4/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
class StubGenerator {
    private static func regexForTokens(_ tokens: [Lexer.Token]) -> String {
        var regex = ""
        for token in tokens {
            if case Lexer.Token.match(_, let m) = token {
                regex += NSRegularExpression
                    .escapedPattern(for: m)
                    .replacingOccurrences(of: "\\", with: "\\\\", options: [], range: nil)
                    .replacingOccurrences(of: "\"", with: "\\\"", options: [], range: nil)
            } else if case Lexer.Token.string(_, _) = token {
                regex += "\\\"(.*?)\\\""
            } else if case Lexer.Token.integer(_, _) = token {
                regex += "(\\\\d+)"
            }
        }
        return regex.trimmingCharacters(in: .whitespaces)
    }

    static func getStubs(for features: [Feature]) -> [String] {
        var methods = [Method]()
        var lookup = [String: Method]()
        let executableSteps = features.taggedElements(askImplementor: false)
            .flatMap { $0.scenarios }.taggedElements(askImplementor: true)
            .flatMap { $0.steps }
            .sorted { $0.keyword.rawValue < $1.keyword.rawValue }
        executableSteps.filter { !$0.canExecute }.forEach {
            let regex = regexForTokens($0.tokens)
            let stringCount = $0.tokens.filter { $0.isString() }.count
            let integerCount = $0.tokens.filter { $0.isInteger() }.count
            let matchesParameter = (stringCount > 0 || integerCount > 0) ? "matches" : "_"
            let variables = [(type: "string", count: stringCount),
                             (type: "integer", count: integerCount),
                             (type: "dataTable", count: $0.dataTable != nil ? 1 : 0),
                             (type: "docString", count: $0.docString != nil ? 1 : 0)]
            let method = Method(keyword: $0.keyword, regex: regex, matchesParameter: matchesParameter, variables: variables)
            if let m = lookup[regex],
                !m.keyword.contains($0.keyword) {
                    m.insertKeyword($0.keyword)
            } else {
                methods.append(method)
                lookup[regex] = method
            }
        }
        return methods.map { method in
            let implementedSteps = executableSteps.filter { $0.canExecute }
            let canMatchAll = !(implementedSteps.contains { !$0.match.matches(for: method.regex).isEmpty })
            let overwrittenSteps = implementedSteps.filter { method.keyword.contains($0.keyword) && !$0.match.matches(for: method.regex).isEmpty }
            if !overwrittenSteps.isEmpty {
                method.comment = "//FIXME: WARNING: This will overwite your implementation for the step(s):\n"
                method.comment += overwrittenSteps.map { "//                \($0.keyword.toString()) \($0.match)" }.joined(separator: "\n")
                method.comment += "\n"
            }
            return method.generateSwift(matchAllAllowed: canMatchAll)
        }
    }
}
