//
//  Cucumber.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
import CucumberSwiftExpressions

#if canImport(CucumberSwift_ObjC)
import CucumberSwift_ObjC
#endif

@objc public class Cucumber: NSObject {
    static var shared: Cucumber = {
        Cucumber()
    }()

    var features = [Feature]()
    var currentStep: Step?
    var reportName: String = "CucumberTestResultsFor"
    var environment: [String: String] = ProcessInfo.processInfo.environment

    private var _beforeFeatureHooks = [FeatureHook]()
    var beforeFeatureHooks: [FeatureHook] {
        get {
            _beforeFeatureHooks.sorted()
        } set {
            _beforeFeatureHooks = newValue
        }
    }
    private var _afterFeatureHooks = [FeatureHook]()
    var afterFeatureHooks: [FeatureHook] {
        get {
            _afterFeatureHooks.sorted()
        } set {
            _afterFeatureHooks = newValue
        }
    }
    private var _beforeScenarioHooks = [ScenarioHook]()
    var beforeScenarioHooks: [ScenarioHook] {
        get {
            _beforeScenarioHooks.sorted()
        } set {
            _beforeScenarioHooks = newValue
        }
    }
    private var _afterScenarioHooks = [ScenarioHook]()
    var afterScenarioHooks: [ScenarioHook] {
        get {
            _afterScenarioHooks.sorted()
        } set {
            _afterScenarioHooks = newValue
        }
    }
    private var _beforeStepHooks = [StepHook]()
    var beforeStepHooks: [StepHook] {
        get {
            _beforeStepHooks.sorted()
        } set {
            _beforeStepHooks = newValue
        }
    }
    private var _afterStepHooks = [StepHook]()
    var afterStepHooks: [StepHook] {
        get {
            _afterStepHooks.sorted()
        } set {
            _afterStepHooks = newValue
        }
    }

    var hookedFeatures       = [Feature]()
    var hookedScenarios      = [Scenario]()
    var failedScenarios      = [Scenario]()
    lazy var reporters: [CucumberTestObserver] = {
        ([CucumberJSONReporter()] + ((self as? CucumberTestObservable)?.observers ?? [])).compactMap { $0 }
    }()

    override public init() {
        super.init()
        XCTestObservationCenter.shared.addTestObserver(self)
    }

    init(withString string: String) {
        super.init()
        parseIntoFeatures(string)
    }

    @objc public static func Load() {
        //        guard let testSuiteInit = class_getClassMethod(XCTestSuite.self, #selector(XCTestSuite.init(forTestCaseWithName:))),
        //              let swizzledInit = class_getClassMethod(self, #selector(Cucumber.testCaseWith(name:))) else {
        //            return
        //        }
        //        method_exchangeImplementations(testSuiteInit, swizzledInit)

        guard let testCaseInit = class_getClassMethod(XCTestCase.self, #selector(XCTestCase.init(selector:))),
              let swizzledInit = class_getClassMethod(self, #selector(Cucumber.testCase(selector:))) else {
            return
        }

        method_exchangeImplementations(testCaseInit, swizzledInit)
    }

    @objc static func testCaseWith(name: String) -> XCTestSuite? {
        if name == "CucumberTest" {
            return CucumberTest.defaultTestSuite
        }

        guard let className = name.components(separatedBy: "/").first,
              let testCaseClass = Bundle.allBundles.compactMap({
                  $0.classNamed(className)
              }).first else { return nil }

        return XCTestSuite(forTestCaseClass: testCaseClass)
    }

    @objc static func testCase(selector: Selector) -> XCTestCase {
        fatalError("Should trigger")
    }

    func readFromFeaturesFolder(in testBundle: Bundle) {
        let featuresURL = { () -> URL in
            if let relativePath = (testBundle.infoDictionary?["FeaturesPath"] as? String) {
                return testBundle.bundleURL.appendingPathComponent(relativePath)
            } else if let featuresPath = testBundle.url(forResource: "Features", withExtension: nil) {
                return featuresPath
            } else {
                return testBundle.bundleURL.appendingPathComponent("Features")
            }
        }()
        let enumerator: FileManager.DirectoryEnumerator? = FileManager.default.enumerator(at: featuresURL, includingPropertiesForKeys: nil)
        while let url = enumerator?.nextObject() as? URL {
            if (url.pathExtension == "feature"),
               let string = try? String(contentsOf: url, encoding: .utf8) {
                Cucumber.shared.parseIntoFeatures(string, uri: url.absoluteString)
            }
        }
    }

    func setupBeforeHooksFor(_ step: Step) {
        if let feature = step.scenario?.feature,
           !hookedFeatures.contains(where: { $0 === feature }) {
            hookedFeatures.append(feature)
            beforeFeatureHooks.forEach { $0.hook(feature) }
            reporters.forEach { $0.didStart(feature: feature, at: Date()) }
        }
        if let scenario = step.scenario,
           !hookedScenarios.contains(where: { $0 === scenario }) {
            hookedScenarios.append(scenario)
            beforeScenarioHooks.forEach { $0.hook(scenario) }
            scenario.startDate = Date()
            reporters.forEach { $0.didStart(scenario: scenario, at: scenario.startDate) }
        }
    }

    func setupAfterHooksFor(_ step: Step) {
        if let scenario = step.scenario,
           let lastScenarioStep = scenario.steps.last,
           lastScenarioStep === step {
            Cucumber.shared.afterScenarioHooks.forEach { $0.hook(scenario) }
            let result: Reporter.Result = (scenario.steps.contains { $0.result == .failed }) ? .failed : .passed
            reporters.forEach { $0.didFinish(scenario: scenario,
                                             result: result,
                                             duration: Measurement(value: Date().timeIntervalSince(scenario.startDate),
                                                                   unit: .seconds))
            }
        }
        if let feature = step.scenario?.feature,
           let lastStep = feature.scenarios.last(where: { !$0.steps.isEmpty })?.steps.last,
           lastStep === step {
            Cucumber.shared.afterFeatureHooks.forEach { $0.hook(feature) }
            let result: Reporter.Result = (feature.scenarios.contains { $0.steps.contains { $0.result == .failed } }) ? .failed : .passed
            reporters.forEach { $0.didFinish(feature: feature,
                                             result: result,
                                             duration: Measurement(value: Date().timeIntervalSince(feature.startDate),
                                                                   unit: .seconds))
            }
        }
    }

    func parseIntoFeatures(_ string: String, uri: String = "") {
        let tokens = Lexer(string, uri: uri).lex()
        features.append(contentsOf: AST.standard.parse(tokens, inFile: uri)
            .map { Feature(with: $0, uri: uri) })
    }

    func attachClosureToSteps(keyword: Step.Keyword? = nil, regex: String, callback: @escaping (([String], Step) throws -> Void), line: Int, file: StaticString) {
        features
            .flatMap { $0.scenarios.flatMap { $0.steps } }
            .filter { step -> Bool in
                if  let k = keyword,
                    step.keyword.contains(k) {
                    return !step.match.matches(for: regex).isEmpty
                } else if keyword == nil {
                    return !step.match.matches(for: regex).isEmpty
                }
                return false
            }
            .forEach { step in
                step.result = .undefined
                step.execute = { try callback(step.match.matches(for: step.regex), step) }
                step.regex = regex
                step.sourceLine = line
                step.sourceFile = file
            }
    }

    func attachClosureToSteps(keyword: Step.Keyword? = nil,
                              expression: CucumberExpression,
                              callback: @escaping ((CucumberSwiftExpressions.Match, Step) throws -> Void),
                              line: Int,
                              file: StaticString) {
        features
            .flatMap { $0.scenarios.flatMap { $0.steps } }
            .filter { step -> Bool in
                if  let k = keyword,
                    step.keyword.contains(k) {
                    return expression.match(in: step.match) != nil
                } else if keyword == nil {
                    return expression.match(in: step.match) != nil
                }
                return false
            }
            .forEach { step in
                step.result = .undefined
                step.execute = { try callback(try XCTUnwrap(expression.match(in: step.match)), step) }
                step.sourceLine = line
                step.sourceFile = file
            }
    }

#if compiler(>=5.7) && canImport(_StringProcessing)
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    func attachClosureToSteps<Output>(keyword: Step.Keyword? = nil,
                                      regex: Regex<Output>,
                                      callback: @escaping ((Regex<Output>.Match, Step) throws -> Void),
                                      line: Int,
                                      file: StaticString) {
        features
            .flatMap { $0.scenarios.flatMap { $0.steps } }
            .filter { step -> Bool in
                if  let k = keyword,
                    step.keyword.contains(k) {
                    let match = try? regex.wholeMatch(in: step.match)
                    return match != nil
                } else if keyword == nil {
                    let match = try? regex.wholeMatch(in: step.match)
                    return match != nil
                }
                return false
            }
            .forEach { step in
                step.result = .undefined
                step.execute = { try callback(try XCTUnwrap(regex.wholeMatch(in: step.match)), step) }
                step.sourceLine = line
                step.sourceFile = file
            }
    }
#endif

    func attachClosureToSteps(keyword: Step.Keyword? = nil, regex: String, class: AnyClass, selector: Selector, line: Int, file: StaticString) {
        features
            .flatMap { $0.scenarios.flatMap { $0.steps } }
            .filter { step -> Bool in
                if  let k = keyword,
                    step.keyword.contains(k) {
                    return !step.match.matches(for: regex).isEmpty
                } else if keyword == nil {
                    return !step.match.matches(for: regex).isEmpty
                }
                return false
            }
            .forEach { step in
                step.result = .undefined
                step.executeSelector = selector
                step.executeClass = `class`
                step.regex = regex
                step.sourceLine = line
                step.sourceFile = file
            }
    }
}

@nonobjc extension XCTestCase {
    @objc override public class func beforeParallelization() {
        Cucumber.Load()
    }
}
