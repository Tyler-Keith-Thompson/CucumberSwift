//
//  Step.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
public class Step : NSObject {
    override public var description: String {
        return "TAGS:\(tags)\n\(keyword ?? .given): \(match)"
    }
    
    public struct Keyword: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public init?(_ str:String) {
            var set:Keyword = []
            if (Scope.language.matchesGiven(str)) {
                set.insert(.given)
            }
            if (Scope.language.matchesWhen(str)) {
                set.insert(.when)
            }
            if (Scope.language.matchesThen(str)) {
                set.insert(.then)
            }
            if (Scope.language.matchesAnd(str)) {
                set.insert(.and)
            }
            if (Scope.language.matchesBut(str)) {
                set.insert(.but)
            }
            guard !set.isEmpty else { return nil }
            self = set
        }
        
        public func toString() -> String {
            if (contains(Keyword.given)) {
                return "Given"
            }
            if (contains(Keyword.when)) {
                return "When"
            }
            if (contains(Keyword.then)) {
                return "Then"
            }
            if (contains(Keyword.and)) {
                return "And"
            }
            if (contains(Keyword.but)) {
                return "But"
            }
            return "UNKNOWN"
        }
        
        public static let given = Keyword(rawValue: 1 << 0)
        public static let when  = Keyword(rawValue: 1 << 1)
        public static let then  = Keyword(rawValue: 1 << 2)
        public static let and   = Keyword(rawValue: 1 << 3)
        public static let but   = Keyword(rawValue: 1 << 4)
    }
    
    public enum Result {
        case passed
        case failed
        case skipped
        case pending
        case undefined
        case ambiguous
    }
    
    public private(set)  var match = ""
    public private(set)  var keyword:Keyword?
    public internal(set) var tags = [String]()
    public internal(set) var scenario:Scenario?

    var result:Result = .pending
    var execute:(([String]) -> Void)? = nil
    var regex:String = ""
    var errorMessage:String = ""
    
    init(with node:StepNode) {
        for token in node.tokens {
            if case Token.keyword(let kw) = token {
                keyword = kw
            } else if case Token.match(let m) = token {
                match += m
            } else if case Token.string(let s) = token {
                match += "\"\(s)\""
            }
        }
        self.match = self.match.trimmingCharacters(in: .whitespaces)
    }
    
    func toJSON() -> [String:Any] {
        return [
            "result":["status":"\(result)", "error_message" : errorMessage],
            "name":"\(match)",
            "keyword":"\(keyword ?? .given)"
        ]
    }
}
