//
//  Cucumber.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@objc public class Cucumber: NSObject, XCTestObservation {

    static var shared:Cucumber = {
       return Cucumber()
    }()
    
    var features = [Feature]()
    var currentStep:Step? = nil
    var reportName:String = "CucumberTestResultsFor"
    var environment:[String:String] = ProcessInfo.processInfo.environment
    var BeforeFeature  :((Feature)  -> Void)?
    var AfterFeature   :((Feature)  -> Void)?
    var BeforeScenario :((Scenario) -> Void)?
    var AfterScenario  :((Scenario) -> Void)?
    var BeforeStep     :((Step)     -> Void)?
    var AfterStep      :((Step)     -> Void)?
    var didCreateTestSuite = false
    var hookedFeatures = [Feature]()
    var hookedScenarios = [Scenario]()

    override public init() {
        super.init()
        XCTestObservationCenter.shared.addTestObserver(self)
    }
    
    init(withString string:String) {
        super.init()
        parseIntoFeatures(string)
    }
    @available(*, deprecated: 1.1, message: "CucumberSwift no longer needs to be instantiated directly, check out the docs for more information")
    public init(withDirectory directory:String, inBundle bundle:Bundle, reportName:String = "CucumberTestResults.json") {
        super.init()
        self.reportName = reportName
        let enumerator:FileManager.DirectoryEnumerator? = FileManager.default.enumerator(at: bundle.bundleURL.appendingPathComponent(directory), includingPropertiesForKeys: nil)
        while let url = enumerator?.nextObject() as? URL {
            if (url.pathExtension == "feature") {
                if let string = try? String(contentsOf: url, encoding: .utf8) {
                    parseIntoFeatures(string, uri: url.absoluteString)
                }
            }
        }
        XCTestObservationCenter.shared.addTestObserver(self)
    }
    
    func readFromFeaturesFolder(in testBundle:Bundle) {
        let enumerator:FileManager.DirectoryEnumerator? = FileManager.default.enumerator(at: testBundle.bundleURL.appendingPathComponent("Features"), includingPropertiesForKeys: nil)
        while let url = enumerator?.nextObject() as? URL {
            if (url.pathExtension == "feature") {
                if let string = try? String(contentsOf: url, encoding: .utf8) {
                    Cucumber.shared.parseIntoFeatures(string, uri: url.absoluteString)
                }
            }
        }
    }
    
    func generateStubsInTestSuite(_ suite:XCTestSuite) {
        let generatedSwift = Cucumber.shared.generateUnimplementedStepDefinitions()
        if (!generatedSwift.isEmpty) {
            suite.addTest(XCTestCaseGenerator.initWithClassName("Generated Steps", XCTestCaseMethod(name: "Generated Steps", closure: {
                XCTContext.runActivity(named: "Pending Steps") { activity in
                    let attachment = XCTAttachment(uniformTypeIdentifier: "swift", name: "GENERATED_Unimplemented_Step_Definitions.swift", payload: generatedSwift.data(using: .utf8), userInfo: nil)
                    attachment.lifetime = .keepAlways
                    activity.add(attachment)
                }
            }))!)
        }
    }
    
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
                        guard step.result != .skipped else { return }
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
                        Cucumber.shared.AfterStep?(step)
                        Cucumber.shared.setupAfterHooksFor(step)
                        step.endTime = Date()
                    }))
                    testCase?.continueAfterFailure = false
                    tests.append(testCase)
                }
            }
        }
        tests.compactMap { $0 }.forEach { testSuite.addTest($0) }
    }
    
    func setupBeforeHooksFor(_ step:Step) {
        if let feature = step.scenario?.feature,
           !hookedFeatures.contains(where: { $0 === feature }) {
            hookedFeatures.append(feature)
            Cucumber.shared.BeforeFeature?(feature)
        }
        if let scenario = step.scenario,
            !hookedScenarios.contains(where: { $0 === scenario }) {
            hookedScenarios.append(scenario)
            Cucumber.shared.BeforeScenario?(scenario)
        }
    }
    
    func setupAfterHooksFor(_ step:Step) {
        if let scenario = step.scenario,
            let lastScenarioStep = scenario.steps.last,
            lastScenarioStep === step {
            Cucumber.shared.AfterScenario?(scenario)
        }
        if let feature = step.scenario?.feature,
            let lastStep = feature.scenarios.filter({ !$0.steps.isEmpty }).last?.steps.last,
            lastStep === step {
            Cucumber.shared.AfterFeature?(feature)
        }
    }
    
    public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        Cucumber.shared.currentStep?.result = .failed
        Cucumber.shared.currentStep?.errorMessage = description
        Cucumber.shared.currentStep?.endTime = Date()
        Cucumber.shared.features.flatMap { $0.scenarios }.flatMap{ $0.steps }.filter{ $0.result == .pending }.forEach { $0.result = .skipped}
    }
    
    func parseIntoFeatures(_ string:String, uri:String = "") {
        let tokens = Lexer(string).lex()
        let ast = AST(tokens)
        features.append(contentsOf: ast.featureNodes
            .map { Feature(with: $0, uri:uri) })
    }
    
    @discardableResult func generateUnimplementedStepDefinitions() -> String {
        var generatedSwift = ""
        let stubs = StubGenerator.getStubs(for: features)
        if (!stubs.isEmpty) {
            generatedSwift = stubs.joined(separator: "\n")
        }
        return generatedSwift
    }
    
    func attachClosureToSteps(keyword:Step.Keyword? = nil, regex:String, callback:@escaping (([String], Step) -> Void)) {
        features
        .flatMap { $0.scenarios.flatMap { $0.steps } }
        .filter { (step) -> Bool in
            if  let k = keyword,
                step.keyword.contains(k) {
                return !step.match.matches(for: regex).isEmpty
            } else if (keyword == nil) {
                return !step.match.matches(for: regex).isEmpty
            }
            return false
        }.forEach { (step) in
            step.result = .undefined
            step.execute = callback
            step.regex = regex
        }
    }
}
