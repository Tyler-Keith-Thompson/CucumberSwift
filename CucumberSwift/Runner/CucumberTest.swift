//
//  CucumberTestCase.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/25/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

class CucumberTest: XCTestCase {
    override class var defaultTestSuite: XCTestSuite {
        let suite = XCTestSuite(forTestCaseClass: CucumberTest.self)
        
        var tests = [XCTestCase?]()
        Reporter.shared.reset()
        Cucumber.shared.features.removeAll()
        if let bundle = (Cucumber.shared as? StepImplementation)?.bundle {
            Cucumber.shared.readFromFeaturesFolder(in: bundle)
        }
        (Cucumber.shared as? StepImplementation)?.setupSteps()
        createTestCaseForStubs(&tests)
        for feature in Cucumber.shared.features.taggedElements(with: Cucumber.shared.environment, askImplementor: false) {
            let className = feature.title.camelCasingString().capitalizingFirstLetter() + "|"
            for scenario in feature.scenarios.taggedElements(with: Cucumber.shared.environment, askImplementor: true) {
                createTestCaseFor(className:className, scenario: scenario, tests: &tests)
            }
        }
        tests.compactMap { $0 }.forEach { suite.addTest($0) }
        return suite
    }
    
    private static func createTestCaseForStubs(_ tests:inout [XCTestCase?]) {
        let generatedSwift = Cucumber.shared.generateUnimplementedStepDefinitions()
        if (!generatedSwift.isEmpty) {
            tests.append(TestCaseGenerator.initWith(className: "Generated Steps", method: TestCaseMethod(withName: "GenerateStepsStubsIfNecessary", closure: {
                XCTContext.runActivity(named: "Pending Steps") { activity in
                    let attachment = XCTAttachment(uniformTypeIdentifier: "swift", name: "GENERATED_Unimplemented_Step_Definitions.swift", payload: generatedSwift.data(using: .utf8), userInfo: nil)
                    attachment.lifetime = .keepAlways
                    activity.add(attachment)
                }
            })))
        }
    }
    
    private static func createTestCaseFor(className:String, scenario: Scenario, tests:inout [XCTestCase?]) {
        for step in scenario.steps {
            let testCase = TestCaseGenerator.initWith(className: className.appending(scenario.title.camelCasingString().capitalizingFirstLetter()), method: TestCaseMethod(withName: "\(step.keyword.toString()) \(step.match)".capitalizingFirstLetter().camelCasingString(), closure: {
                guard !Cucumber.shared.failedScenarios.contains(where: { $0 === step.scenario }) else { return }
                step.startTime = Date()
                Cucumber.shared.currentStep = step
                Cucumber.shared.setupBeforeHooksFor(step)
                Cucumber.shared.BeforeStepHooks.forEach { $0(step) }
                _ = XCTContext.runActivity(named: "\(step.keyword.toString()) \(step.match)") { _ in
                    step.execute?(step.match.matches(for: step.regex), step)
                    if (step.execute != nil && step.result != .failed) {
                        step.result = .passed
                    }
                    Reporter.shared.writeStep(step)
                }
            }))
            testCase?.addTeardownBlock {
                Cucumber.shared.AfterStepHooks.forEach { $0(step) }
                Cucumber.shared.setupAfterHooksFor(step)
                step.endTime = Date()
            }
            testCase?.continueAfterFailure = true
            tests.append(testCase)
        }
    }
    
    //A test case needs at least one test to trigger the observer
    final func testGherkin() {
        XCTAssert(Gherkin.errors.isEmpty, "Gherkin language errors found:\n\(Gherkin.errors.joined(separator: "\n"))")
    }
}
