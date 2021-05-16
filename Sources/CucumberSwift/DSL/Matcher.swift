//
//  Matcher.swift
//  CucumberSwift
//
//  Created by thompsty on 7/23/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation

public protocol Matcher {
    init()
    var keyword: Step.Keyword { get }
}

extension Matcher {
    @discardableResult public init(_ regex: String,
                                   class: AnyClass,
                                   selector: Selector) {
        self.init()
        Cucumber.shared.attachClosureToSteps(keyword: keyword, regex: regex, class: `class`, selector: selector)
    }
    @discardableResult public init(_ regex: String,
                                   callback:@escaping (([String], Step) -> Void)) {
        self.init()
        Cucumber.shared.attachClosureToSteps(keyword: keyword, regex: regex, callback: callback)
    }
}
