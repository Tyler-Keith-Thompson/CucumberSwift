//
//  CucumberTestCase.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/25/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

fileprivate extension Step {
    var method:TestCaseMethod? {
        TestCaseMethod(withName: "\(keyword.toString()) \(match)".toClassString(), closure: {
            guard !Cucumber.shared.failedScenarios.contains(where: { $0 === self.scenario }) else { return }
            self.startTime = Date()
            Cucumber.shared.currentStep = self
            Cucumber.shared.setupBeforeHooksFor(self)
            Cucumber.shared.beforeStepHooks.forEach { $0(self) }
            _ = XCTContext.runActivity(named: "\(self.keyword.toString()) \(self.match)") { _ in
                self.run()
                Reporter.shared.writeStep(self)
            }
        })
    }
    
    func run() {
        if let `class` = executeClass, let selector = executeSelector {
            executeInstance = (`class` as? NSObject.Type)?.init()
            if let instance = executeInstance,
                instance.responds(to: selector) {
                    (executeInstance as? XCTestCase)?.setUp()
                    instance.perform(selector)
            }
        } else {
            execute?(match.matches(for: regex), self)
        }
        if (execute != nil && result != .failed) {
            result = .passed
        }
    }
}

fileprivate extension String {
    func toClassString() -> String {
        camelCasingString().capitalizingFirstLetter()
    }
}

class CucumberTest: XCTestCase {
    override class var defaultTestSuite: XCTestSuite {
        let suite = XCTestSuite(forTestCaseClass: CucumberTest.self)
        
        var tests = [XCTestCase]()
        Reporter.shared.reset()
        Cucumber.shared.features.removeAll()
        if let bundle = (Cucumber.shared as? StepImplementation)?.bundle {
            Cucumber.shared.readFromFeaturesFolder(in: bundle)
        }
        (Cucumber.shared as? StepImplementation)?.setupSteps()
        createTestCaseForStubs(&tests)
        for feature in Cucumber.shared.features.taggedElements(with: Cucumber.shared.environment, askImplementor: false) {
            let className = feature.title.toClassString() + "|"
            for scenario in feature.scenarios.taggedElements(with: Cucumber.shared.environment, askImplementor: true) {
                createTestCaseFor(className:className, scenario: scenario, tests: &tests)
            }
        }
        tests.forEach { suite.addTest($0) }
        return suite
    }
    
    private static func createTestCaseForStubs(_ tests:inout [XCTestCase]) {
        let generatedSwift = Cucumber.shared.generateUnimplementedStepDefinitions()
        guard !generatedSwift.isEmpty else { return }
        if let (testCaseClass, methodSelector) = TestCaseGenerator.initWith(className: "Generated Steps", method: TestCaseMethod(withName: "GenerateStepsStubsIfNecessary", closure: {
            XCTContext.runActivity(named: "Pending Steps") { activity in
                let attachment = XCTAttachment(uniformTypeIdentifier: "swift", name: "GENERATED_Unimplemented_Step_Definitions.swift", payload: generatedSwift.data(using: .utf8), userInfo: nil)
                attachment.lifetime = .keepAlways
                activity.add(attachment)
            }
        })) {
            objc_registerClassPair(testCaseClass)
            tests.append(testCaseClass.init(selector: methodSelector))
        }
    }
    
    private static func createTestCaseFor(className:String, scenario: Scenario, tests:inout [XCTestCase]) {
        scenario.steps.compactMap { step -> (step:Step, XCTestCase.Type, Selector)? in
            if let (testCase, methodSelector) = TestCaseGenerator.initWith(className: className.appending(scenario.title.toClassString()),
                                                                           method: step.method) {
                return (step, testCase, methodSelector)
            }
            return nil
        }.map { (step, testCaseClass, methodSelector) -> (Step, XCTestCase) in
            objc_registerClassPair(testCaseClass)
            return (step, testCaseClass.init(selector: methodSelector))
        }.forEach { (step, testCase) in
            testCase.addTeardownBlock {
                (step.executeInstance as? XCTestCase)?.tearDown()
                Cucumber.shared.afterStepHooks.forEach { $0(step) }
                Cucumber.shared.setupAfterHooksFor(step)
                step.endTime = Date()
            }
            step.continueAfterFailure ?= (Cucumber.shared as? StepImplementation)?.continueTestingAfterFailure ?? testCase.continueAfterFailure
            step.testCase = testCase
            testCase.continueAfterFailure = step.continueAfterFailure
            tests.append(testCase)
        }
    }
    
    //A test case needs at least one test to trigger the observer
    final func testGherkin() {
        XCTAssert(Gherkin.errors.isEmpty, "Gherkin language errors found:\n\(Gherkin.errors.joined(separator: "\n"))")
        Gherkin.errors.forEach {
            XCTFail($0)
        }
    }
}
