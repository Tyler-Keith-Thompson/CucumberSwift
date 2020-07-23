//
//  Globals.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/25/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation

//MARK: Hooks
public func BeforeFeature(closure: @escaping ((Feature) -> Void)) {
    Cucumber.shared.beforeFeatureHooks.append(closure)
}
public func AfterFeature(closure: @escaping ((Feature) -> Void)) {
    Cucumber.shared.afterFeatureHooks.append(closure)
}
public func BeforeScenario(closure: @escaping ((Scenario) -> Void)) {
    Cucumber.shared.beforeScenarioHooks.append(closure)
}
public func AfterScenario(closure: @escaping ((Scenario) -> Void)) {
    Cucumber.shared.afterScenarioHooks.append(closure)
}
public func BeforeStep(closure: @escaping ((Step) -> Void)) {
    Cucumber.shared.beforeStepHooks.append(closure)
}
public func AfterStep(closure: @escaping ((Step) -> Void)) {
    Cucumber.shared.afterStepHooks.append(closure)
}

public protocol Matcher {
    init()
    var keyword:Step.Keyword { get }
}

public extension Matcher {
    @discardableResult init(_ regex:String, class:AnyClass, selector:Selector) {
        self.init()
        Cucumber.shared.attachClosureToSteps(keyword: keyword, regex: regex, class:`class`, selector:selector)
    }
    @discardableResult init(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
        self.init()
        Cucumber.shared.attachClosureToSteps(keyword: keyword, regex: regex, callback:callback)
    }
}

public protocol GherkinDSL {
    init()
}

public extension GherkinDSL {
    @discardableResult fileprivate init(handler: () -> Void) {
        self.init()
        handler()
    }

    @available(*, unavailable, message: "Add () to forward to @autoclosure, To help drive semantically valid Gherkin please pass a single function, not a closure with multiple arguments.")
    @discardableResult init(I handler: () -> Void) { self.init() }
    @discardableResult init(I handler: @autoclosure () -> Void) {
        self.init(handler: handler)
    }

    @available(*, unavailable, message: "Add () to forward to @autoclosure, To help drive semantically valid Gherkin please pass a single function, not a closure with multiple arguments.")
    @discardableResult init(My handler: () -> Void) { self.init() }
    @discardableResult init(My handler: @autoclosure () -> Void) {
        self.init(handler: handler)
    }

    @available(*, unavailable, message: "Add () to forward to @autoclosure, To help drive semantically valid Gherkin please pass a single function, not a closure with multiple arguments.")
    @discardableResult init(A handler: () -> Void) { self.init() }
    @discardableResult init(A handler: @autoclosure () -> Void) {
        self.init(handler: handler)
    }

    @available(*, unavailable, message: "Add () to forward to @autoclosure, To help drive semantically valid Gherkin please pass a single function, not a closure with multiple arguments.")
    @discardableResult init(The handler: () -> Void) { self.init() }
    @discardableResult init(The handler: @autoclosure () -> Void) {
        self.init(handler: handler)
    }
}

public struct GivenDSL: Matcher, GherkinDSL {
    public init() { }
    public var keyword: Step.Keyword = .given
}
public struct WhenDSL: Matcher, GherkinDSL {
    public init() { }
    public var keyword: Step.Keyword = .when
}
public struct ThenDSL: Matcher, GherkinDSL {
    public init() { }
    public var keyword: Step.Keyword = .then
}
public struct AndDSL: Matcher, GherkinDSL {
    public init() { }
    public var keyword: Step.Keyword = .and
}
public struct ButDSL: Matcher, GherkinDSL {
    public init() { }
    public var keyword: Step.Keyword = .but
}
public struct MatchAllDSL: Matcher, GherkinDSL {
    public init() { }
    public var keyword: Step.Keyword = []
}

public typealias Given = GivenDSL
public typealias When = WhenDSL
public typealias Then = ThenDSL
public typealias And = AndDSL
public typealias But = ButDSL
public typealias MatchAll = MatchAllDSL
