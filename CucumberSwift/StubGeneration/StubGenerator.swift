//
//  StubGenerator.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/4/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
class StubGenerator {
    private static func regexForTokens(_ tokens:[Token]) -> String {
        var regex = ""
        for token in tokens {
            if case Token.match(let m) = token {
                regex += NSRegularExpression
                    .escapedPattern(for: m)
                    .replacingOccurrences(of: "\\", with: "\\\\", options: [], range: nil)
                    .replacingOccurrences(of: "\"", with: "\\\"", options: [], range: nil)
            } else if case Token.string(_) = token {
                regex += "\\\"(.*?)\\\""
            } else if case Token.integer(_) = token {
                regex += "(\\\\d+)"
            }
        }
        return regex.trimmingCharacters(in: .whitespaces)
    }
    
    static func getStubs(for features:[Feature]) -> [String] {
        var methods = [Method]()
        var lookup = [String:Method]()
        let executableSteps = features.taggedElements()
            .flatMap{ $0.scenarios }.taggedElements()
            .flatMap{ $0.steps }
            .sorted{ $0.keyword.rawValue < $1.keyword.rawValue }
        executableSteps.filter{ $0.execute == nil }.forEach {
            let regex = regexForTokens($0.tokens)
            let stringCount = $0.tokens.filter { $0.isString() }.count
            let integerCount = $0.tokens.filter { $0.isInteger() }.count
            let matchesParameter = (stringCount > 0 || integerCount > 0) ? "matches" : "_"
            let variables = [(type: "string", count: stringCount),
                             (type: "integer", count: integerCount)]
            var method = Method(keyword: $0.keyword, regex: regex, matchesParameter: matchesParameter, variables: variables)
            if let m = lookup[regex] {
                method = m
                if (!method.keyword.contains($0.keyword)) {
                    method.insertKeyword($0.keyword)
                }
            } else {
                methods.append(method)
                lookup[regex] = method
            }
        }
        return methods.map { method in
            let implementedSteps = executableSteps.filter { $0.execute != nil }
            let canMatchAll = !(implementedSteps.contains { !$0.match.matches(for: method.regex).isEmpty })
            let overwrittenSteps = implementedSteps.filter{ method.keyword.contains($0.keyword) && !$0.match.matches(for: method.regex).isEmpty }
            if (!overwrittenSteps.isEmpty) {
                method.comment = "//FIXME: WARNING: This will overwite your implementation for the step(s):\n"
                method.comment += overwrittenSteps.map { "//                \($0.keyword.toString()) \($0.match)" }.joined(separator: "\n")
                method.comment += "\n"
            }
            return method.generateSwift(matchAllAllowed: canMatchAll)
        }
    }
}
