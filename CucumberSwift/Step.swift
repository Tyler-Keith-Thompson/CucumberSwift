//
//  Step.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
public class Step : Taggable, CustomStringConvertible {
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
    init(with line:(scope: Scope, string: String)) {
        //Regex here slows us down at massive scale, hence the subscripts
        if let keywordEndIndex = line.string.index(of: " ") {
            keyword = Keyword(rawValue: String(line.string[...keywordEndIndex]).trimmingCharacters(in: .whitespaces))
            match = String(line.string[keywordEndIndex...]).trimmingCharacters(in: .whitespaces)
        }
    }
    
    init(with line:[Token]) {
        var lineCopy = line
        if let firstIdentifier = line.firstIdentifier(),
            case Token.identifier(let id) = firstIdentifier {
            let s = Scope.scopeFor(str: id)
            if (s == .step) {
                keyword = Keyword(rawValue: id.lowercased().trimmingCharacters(in: .whitespaces))
                lineCopy.removeFirst()
                match += lineCopy.stringAggregate
            }
        }
    }
    
    func containsTags(_ tags:[String]) -> Bool {
        if (!tags.filter{ containsTag($0) }.isEmpty) {
            return true
        }
        return false
    }
    
    func toJSON() -> [String:Any] {
        return [
            "result":["status":"\(result)", "error_message" : errorMessage],
            "name":"\(match)",
            "keyword":"\(keyword ?? .given)"
        ]
    }
}
