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
