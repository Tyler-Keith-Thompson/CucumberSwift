//
//  Cucumber.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

@objc public class Cucumber: NSObject {

    static var shared:Cucumber = {
       return Cucumber()
    }()
    
    var features = [Feature]()
    var currentStep:Step? = nil
    var reportName:String = "CucumberTestResultsFor"
    var environment:[String:String] = ProcessInfo.processInfo.environment
    var BeforeFeatureHooks  = [(Feature)  -> Void]()
    var AfterFeatureHooks   = [(Feature)  -> Void]()
    var BeforeScenarioHooks = [(Scenario)  -> Void]()
    var AfterScenarioHooks  = [(Scenario)  -> Void]()
    var BeforeStepHooks     = [(Step)  -> Void]()
    var AfterStepHooks      = [(Step)  -> Void]()
    var hookedFeatures      = [Feature]()
    var hookedScenarios     = [Scenario]()
    var failedScenarios     = [Scenario]()

    override public init() {
        super.init()
        XCTestObservationCenter.shared.addTestObserver(self)
    }
    
    init(withString string:String) {
        super.init()
        parseIntoFeatures(string)
    }
    
    func readFromFeaturesFolder(in testBundle:Bundle) {
        let relativePath = (testBundle.infoDictionary?["FeaturesPath"] as? String) ?? "Features"
        let enumerator:FileManager.DirectoryEnumerator? = FileManager.default.enumerator(at: testBundle.bundleURL.appendingPathComponent(relativePath), includingPropertiesForKeys: nil)
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
            suite.addTest(TestCaseGenerator.initWith(className: "Generated Steps", method: TestCaseMethod(withName: "Generated Steps", closure: {
                XCTContext.runActivity(named: "Pending Steps") { activity in
                    let attachment = XCTAttachment(uniformTypeIdentifier: "swift", name: "GENERATED_Unimplemented_Step_Definitions.swift", payload: generatedSwift.data(using: .utf8), userInfo: nil)
                    attachment.lifetime = .keepAlways
                    activity.add(attachment)
                }
            }))!)
        }
    }
    
    func setupBeforeHooksFor(_ step:Step) {
        if let feature = step.scenario?.feature,
           !hookedFeatures.contains(where: { $0 === feature }) {
            hookedFeatures.append(feature)
            Cucumber.shared.BeforeFeatureHooks.forEach { $0(feature) }
        }
        if let scenario = step.scenario,
            !hookedScenarios.contains(where: { $0 === scenario }) {
            hookedScenarios.append(scenario)
            Cucumber.shared.BeforeScenarioHooks.forEach { $0(scenario) }
        }
    }
    
    func setupAfterHooksFor(_ step:Step) {
        if let scenario = step.scenario,
            let lastScenarioStep = scenario.steps.last,
            lastScenarioStep === step {
            Cucumber.shared.AfterScenarioHooks.forEach { $0(scenario) }
        }
        if let feature = step.scenario?.feature,
            let lastStep = feature.scenarios.filter({ !$0.steps.isEmpty }).last?.steps.last,
            lastStep === step {
            Cucumber.shared.AfterFeatureHooks.forEach { $0(feature) }
        }
    }
    
    func parseIntoFeatures(_ string:String, uri:String = "") {
        let tokens = Lexer(string, uri:uri).lex()
        features.append(contentsOf: AST.standard.parse(tokens)
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
    
    func attachClosureToSteps(keyword:Step.Keyword? = nil, regex:String, class:AnyClass, selector:Selector) {
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
                step.executeSelector = selector
                step.executeClass = `class`
                step.regex = regex
        }
    }
}
