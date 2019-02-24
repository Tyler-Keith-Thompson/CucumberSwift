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
    Cucumber.shared.BeforeFeatureHooks.append(closure)
}
public func AfterFeature(closure: @escaping ((Feature) -> Void)) {
    Cucumber.shared.AfterFeatureHooks.append(closure)
}
public func BeforeScenario(closure: @escaping ((Scenario) -> Void)) {
    Cucumber.shared.BeforeScenarioHooks.append(closure)
}
public func AfterScenario(closure: @escaping ((Scenario) -> Void)) {
    Cucumber.shared.AfterScenarioHooks.append(closure)
}
public func BeforeStep(closure: @escaping ((Step) -> Void)) {
    Cucumber.shared.BeforeStepHooks.append(closure)
}
public func AfterStep(closure: @escaping ((Step) -> Void)) {
    Cucumber.shared.AfterStepHooks.append(closure)
}

//MARK Steps
public func Given(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
    Cucumber.shared.attachClosureToSteps(keyword: .given, regex: regex, callback:callback)
}
public func When(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
    Cucumber.shared.attachClosureToSteps(keyword: .when, regex: regex, callback:callback)
}
public func Then(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
    Cucumber.shared.attachClosureToSteps(keyword: .then, regex: regex, callback:callback)
}
public func And(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
    Cucumber.shared.attachClosureToSteps(keyword: .and, regex: regex, callback:callback)
}
public func But(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
    Cucumber.shared.attachClosureToSteps(keyword: .but, regex: regex, callback:callback)
}
public func MatchAll(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
    Cucumber.shared.attachClosureToSteps(regex: regex, callback:callback)
}
