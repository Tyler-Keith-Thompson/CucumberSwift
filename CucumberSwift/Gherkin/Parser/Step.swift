//
//  Step.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
public class Step : CustomStringConvertible {
    public var description: String {
        return "TAGS:\(tags)\n\(keyword ?? .given): \(match)"
    }
    
    public enum Keyword:String {
        case given = "given"
        case when = "when"
        case then = "then"
        case and = "and"
        case or = "or"
        case but = "but"
        
        static var all:[Keyword] {
            return [
                .given,
                .when,
                .then,
                .and,
                .or,
                .but
            ]
        }
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
//            else if case Token.integer(let i) = token {
//                match += String(describing: i)
//            } else if case Token.double(let d) = token {
//                match += String(describing: d)
//            }
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
