//
//  Method.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/4/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
class Method {
    var keyword:Step.Keyword = []
    var keywords:[Step.Keyword] = []
    var comment = ""
    private(set) var regex = ""
    private(set) var matchesParameter = ""
    private(set) var variables:[(type:String, count:Int)] = []
    init(keyword:Step.Keyword, regex:String, matchesParameter:String, variables:[(type:String, count:Int)]) {
        self.keyword = keyword
        self.keywords = [keyword]
        self.regex = regex
        self.matchesParameter = matchesParameter
        self.variables = variables
    }
    
    func insertKeyword(_ keyword:Step.Keyword) {
        keywords.append(keyword)
        self.keyword.insert(keyword)
    }
    
    func generateSwift(matchAllAllowed:Bool = true) -> String {
        var keywordStrings = [String]()
        if (keyword.hasMultipleValues() && matchAllAllowed) {
            keywordStrings.append("MatchAll")
        } else if (!matchAllAllowed && keyword.hasMultipleValues()) {
            keywordStrings.append(contentsOf: keywords.map { $0.toString() })
        } else {
            keywordStrings.append(keyword.toString())
        }
        var methodStrings = [String]()
        for keywordString in keywordStrings {
            var methodString = "\(keywordString.capitalizingFirstLetter())(\"^\(regex.trimmingCharacters(in: .whitespacesAndNewlines))$\") { \(matchesParameter), _ in\n"
            for variable in variables {
                guard variable.count > 0 else { continue }
                for i in 1...variable.count {
                    let spelledNumber = NumberFormatter.localizedString(from: NSNumber(integerLiteral: i),
                                                                        number: .spellOut)
                    let varName = "\(variable.type) \(spelledNumber)".camelCasingString()
                    methodString += "    let \(varName) = \(matchesParameter)[\(i)]\n"
                }
            }
            if (variables.reduce(0) { $0 + $1.count } <= 0) {
                methodString += "\n"
            }
            methodString += "}"
            methodStrings.append(methodString)
        }
        return comment + methodStrings.joined(separator: "\n")
    }
}
