//
//  TestObservation.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/26/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

extension Cucumber: XCTestObservation {
    public func testBundleWillStart(_ testBundle: Bundle) {
        Cucumber.shared.features.removeAll()
        readFromFeaturesFolder(in: testBundle)
    }
    
    public func testBundleDidFinish(_ testBundle: Bundle) {
        DispatchQueue.main.async {
            let name = Cucumber.shared.reportName.appending(String(testBundle.bundleURL.lastPathComponent.prefix(while: { $0 != "."}))).appending(".json")
            if  let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false),
                let data = try? JSONSerialization.data(withJSONObject: Cucumber.shared.features.map { $0.toJSON() }, options: JSONSerialization.WritingOptions.prettyPrinted) {
                let fileURL = documentDirectory.appendingPathComponent(name)
                try? data.write(to: fileURL)
            }
        }
    }
    
    public func testSuiteWillStart(_ testSuite: XCTestSuite) {
        guard !Cucumber.shared.didCreateTestSuite else { return }
        Cucumber.shared.didCreateTestSuite = true
        var tests = [XCTestCase?]()
        (Cucumber.shared as? StepImplementation)?.setupSteps()
        let generatedSwift = Cucumber.shared.generateUnimplementedStepDefinitions()
        if (!generatedSwift.isEmpty) {
            tests.append(XCTestCaseGenerator.initWithClassName("Generated Steps", XCTestCaseMethod(name: "GenerateStepsStubsIfNecessary", closure: {
                XCTContext.runActivity(named: "Pending Steps") { activity in
                    let attachment = XCTAttachment(uniformTypeIdentifier: "swift", name: "GENERATED_Unimplemented_Step_Definitions.swift", payload: generatedSwift.data(using: .utf8), userInfo: nil)
                    attachment.lifetime = .keepAlways
                    activity.add(attachment)
                }
            })))
        }
        for feature in Cucumber.shared.features.taggedElements(with: environment) {
            let className = feature.title.camelCasingString().capitalizingFirstLetter() + "|"
            for scenario in feature.scenarios.taggedElements(with: environment) {
                for step in scenario.steps {
                    let testCase = XCTestCaseGenerator.initWithClassName(className.appending(scenario.title.camelCasingString().capitalizingFirstLetter()), XCTestCaseMethod(name: "\(step.keyword.toString()) \(step.match)".capitalizingFirstLetter().camelCasingString(), closure: {
                        guard !Cucumber.shared.failedScenarios.contains(where: { $0 === step.scenario }) else { return }
                        step.startTime = Date()
                        Cucumber.shared.currentStep = step
                        Cucumber.shared.setupBeforeHooksFor(step)
                        Cucumber.shared.BeforeStep?(step)
                        _ = XCTContext.runActivity(named: "\(step.keyword.toString()) \(step.match)") { _ in
                            step.execute?(step.match.matches(for: step.regex), step)
                            if (step.execute != nil && step.result != .failed) {
                                step.result = .passed
                            }
                        }
                    }))
                    testCase?.addTeardownBlock {
                        Cucumber.shared.AfterStep?(step)
                        Cucumber.shared.setupAfterHooksFor(step)
                        step.endTime = Date()
                    }
                    testCase?.continueAfterFailure = true
                    tests.append(testCase)
                }
            }
        }
        tests.compactMap { $0 }.forEach { testSuite.addTest($0) }
    }
    public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        Cucumber.shared.currentStep?.result = .failed
        Cucumber.shared.currentStep?.errorMessage = description
        Cucumber.shared.currentStep?.endTime = Date()
        guard let scenario = Cucumber.shared.currentStep?.scenario else {
            return
        }
        Cucumber.shared.failedScenarios.append(scenario)
        var foundStep = false
        scenario.steps.forEach { (step) in
            if step === Cucumber.shared.currentStep {
                foundStep = true
            } else if (foundStep && step.result == .pending) {
                step.result = .skipped
            }
        }
    }
}
