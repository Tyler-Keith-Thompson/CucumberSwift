//
//  Step.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
public class Step {
    public enum Keyword:String {
        case given = "Given"
        case when = "When"
        case then = "Then"
        case and = "And"
        case or = "Or"
        case but = "But"
        
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
    public private(set) var match = ""
    public private(set) var keyword:Keyword?
    var execute:(([String]) -> Void)? = nil
    var regex:String = ""
    init(with line:(scope: Scope, string: String)) {
        //Regex here slows us down at massive scale, hence the subscripts
        if let keywordEndIndex = line.string.index(of: " ") {
            keyword = Keyword(rawValue: String(line.string[...keywordEndIndex]).trimmingCharacters(in: .whitespaces))
            match = String(line.string[keywordEndIndex...]).trimmingCharacters(in: .whitespaces)
        }
    }
}
