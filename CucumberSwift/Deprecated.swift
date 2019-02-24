//
//  Deprecated.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/25/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
//Where methods go to die
extension Cucumber {
    @available(*, deprecated: 1.1, message: "Thanks to some objective-c runtime black magic this method should never be called directly. Set CucumberSwift.Cucumber as your principal class from your info.plist and your cucumber tests will simply run. If you do continue to use this method be aware generated stubs will no longer work.")
    public func executeFeatures() {
        generateUnimplementedStepDefinitions()
        for feature in features.taggedElements(with: environment, askImplementor: false) {
            XCTContext.runActivity(named: "Feature: \(feature.title)") { _ in
                BeforeFeatureHooks.forEach { $0(feature) }
                for scenario in feature.scenarios.taggedElements(with: environment, askImplementor: true) {
                    XCTContext.runActivity(named: "Scenario: \(scenario.title)") { _ in
                        BeforeScenarioHooks.forEach { $0(scenario) }
                        for step in scenario.steps {
                            BeforeStepHooks.forEach { $0(step) }
                            currentStep = step
                            _ = XCTContext.runActivity(named: "\(step.keyword.toString()) \(step.match)") { _ -> String in
                                step.execute?(step.match.matches(for: step.regex), step)
                                if (step.execute != nil && step.result != .failed) {
                                    step.result = .passed
                                }
                                return ""
                            }
                            AfterStepHooks.forEach { $0(step) }
                        }
                        AfterScenarioHooks.forEach { $0(scenario) }
                    }
                }
                AfterFeatureHooks.forEach { $0(feature) }
            }
        }
        DispatchQueue.main.async {
            if  let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false),
                let data = try? JSONSerialization.data(withJSONObject: self.features.map { $0.toJSON() }, options: JSONSerialization.WritingOptions.prettyPrinted) {
                let fileURL = documentDirectory.appendingPathComponent("CucumberTestResults.json")
                try? data.write(to: fileURL)
            }
        }
    }
}
