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
    var beforeFeatureHooks  = [(Feature)  -> Void]()
    var afterFeatureHooks   = [(Feature)  -> Void]()
    var beforeScenarioHooks = [(Scenario)  -> Void]()
    var afterScenarioHooks  = [(Scenario)  -> Void]()
    var beforeStepHooks     = [(Step)  -> Void]()
    var afterStepHooks      = [(Step)  -> Void]()
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
    
    @objc public static func Load() {
        guard let testSuiteInit = class_getClassMethod(XCTestSuite.self, #selector(XCTestSuite.init(forTestCaseWithName:))),
              let swizzledInit = class_getClassMethod(self, #selector(Cucumber.testCaseWith(name:))) else {
            return
        }
        method_exchangeImplementations(testSuiteInit, swizzledInit)
    }
    
    @objc static func testCaseWith(name:String) -> XCTestSuite? {
        if (name == "CucumberTest") {
            return CucumberTest.defaultTestSuite
        }
        
        guard let className = name.components(separatedBy: "/").first,
            let testCaseClass = Bundle.allBundles.compactMap({
                $0.classNamed(className)
            }).first else { return nil }
        
        return XCTestSuite(forTestCaseClass: testCaseClass)
    }
    
    func readFromFeaturesFolder(in testBundle:Bundle) {
        let relativePath = (testBundle.infoDictionary?["FeaturesPath"] as? String) ?? "Features"
        let enumerator:FileManager.DirectoryEnumerator? = FileManager.default.enumerator(at: testBundle.bundleURL.appendingPathComponent(relativePath), includingPropertiesForKeys: nil)
        while let url = enumerator?.nextObject() as? URL {
            if (url.pathExtension == "feature"),
                let string = try? String(contentsOf: url, encoding: .utf8) {
                    Cucumber.shared.parseIntoFeatures(string, uri: url.absoluteString)
            }
        }
    }
    
    func setupBeforeHooksFor(_ step:Step) {
        if let feature = step.scenario?.feature,
           !hookedFeatures.contains(where: { $0 === feature }) {
            hookedFeatures.append(feature)
            Cucumber.shared.beforeFeatureHooks.forEach { $0(feature) }
        }
        if let scenario = step.scenario,
            !hookedScenarios.contains(where: { $0 === scenario }) {
            hookedScenarios.append(scenario)
            Cucumber.shared.beforeScenarioHooks.forEach { $0(scenario) }
        }
    }
    
    func setupAfterHooksFor(_ step:Step) {
        if let scenario = step.scenario,
            let lastScenarioStep = scenario.steps.last,
            lastScenarioStep === step {
            Cucumber.shared.afterScenarioHooks.forEach { $0(scenario) }
        }
        if let feature = step.scenario?.feature,
            let lastStep = feature.scenarios.filter({ !$0.steps.isEmpty }).last?.steps.last,
            lastStep === step {
            Cucumber.shared.afterFeatureHooks.forEach { $0(feature) }
        }
    }
    
    func parseIntoFeatures(_ string:String, uri:String = "") {
        let tokens = Lexer(string, uri:uri).lex()
        features.append(contentsOf: AST.standard.parse(tokens, inFile: uri)
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
