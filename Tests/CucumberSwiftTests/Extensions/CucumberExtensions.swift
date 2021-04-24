//
//  CucumberExtensions.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 3/2/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
@testable import CucumberSwift

extension Cucumber {
    func reset() {
        Cucumber.shouldRunWith = { _, _ in true }
        Reporter.shared.reset()
        Gherkin.errors.removeAll()
        features.removeAll()
        beforeFeatureHooks.removeAll()
        beforeScenarioHooks.removeAll()
        beforeStepHooks.removeAll()
        afterFeatureHooks.removeAll()
        afterScenarioHooks.removeAll()
        afterStepHooks.removeAll()
        environment["CUCUMBER_TAGS"] = nil
        hookedFeatures.removeAll()
        hookedScenarios.removeAll()
    }

    func executeFeatures() {
        CucumberTest.allGeneratedTests.forEach { $0.invokeTest() }
    }
}

