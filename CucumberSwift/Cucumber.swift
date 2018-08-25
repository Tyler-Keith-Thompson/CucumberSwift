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
    var reportName:String = ""
    var environment:[String:String] = ProcessInfo.processInfo.environment
    public var BeforeFeature  :((Feature)  -> Void)?
    public var AfterFeature   :((Feature)  -> Void)?
    public var BeforeScenario :((Scenario) -> Void)?
    public var AfterScenario  :((Scenario) -> Void)?
    public var BeforeStep     :((Step)     -> Void)?
    public var AfterStep      :((Step)     -> Void)?

    override public init() {
        super.init()
        XCTestObservationCenter.shared.addTestObserver(self)
    }
    
    init(withString string:String) {
        super.init()
        parseIntoFeatures(string)
    }
    
    public func testBundleWillStart(_ testBundle: Bundle) {
        Cucumber.shared.reportName = "CucumberTestResults.json"
        let enumerator:FileManager.DirectoryEnumerator? = FileManager.default.enumerator(at: testBundle.bundleURL.appendingPathComponent("Features"), includingPropertiesForKeys: nil)
        while let url = enumerator?.nextObject() as? URL {
            if (url.pathExtension == "feature") {
                if let string = try? String(contentsOf: url, encoding: .utf8) {
                    Cucumber.shared.parseIntoFeatures(string, uri: url.absoluteString)
                }
            }
        }
        let suite = XCTestSuite(name: "CucumberTests")
        for feature in Cucumber.shared.features.taggedElements(with: environment) {
            let className = feature.title.camelCasingString().capitalizingFirstLetter() + "|"
            for scenario in feature.scenarios.taggedElements(with: environment) {
                for step in scenario.steps {
                    currentStep = step
                    let testCase = XCTestCaseGenerator.initWithClassName(className.appending(scenario.title.camelCasingString().capitalizingFirstLetter()), XCTestCaseMethod(name: "\(step.keyword.toString()) \(step.match)".capitalizingFirstLetter().camelCasingString(), closure: {
                        step.execute?(step.match.matches(for: step.regex), step)
                    }))
                    suite.addTest(testCase!)
                }
            }
        }
        suite.run()
    }
    
    public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        currentStep?.result = .failed
        currentStep?.errorMessage = description
    }
    
    @available(*, deprecated: 1.1, message: "CucumberSwift should now be instantiated from your info.plist in your test target, please see the documentation on github for more details.")
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
    
    private func parseIntoFeatures(_ string:String, uri:String = "") {
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
            XCTContext.runActivity(named: "Pending Steps") { activity in
                let attachment = XCTAttachment(uniformTypeIdentifier: "swift", name: "GENERATED_Unimplemented_Step_Definitions.swift", payload: generatedSwift.data(using: .utf8), userInfo: nil)
                attachment.lifetime = .keepAlways
                activity.add(attachment)
            }
        }
        return generatedSwift
    }
    
    @available(*, deprecated: 1.1, message: "Thanks to some objective-c runtime black magic this method should never be called directly. Please see the documentation for details on getting your CucumberSwift tests to run")
    public func executeFeatures() {
        generateUnimplementedStepDefinitions()
        for feature in features.taggedElements(with: environment) {
            XCTContext.runActivity(named: "Feature: \(feature.title)") { _ in
                BeforeFeature?(feature)
                for scenario in feature.scenarios.taggedElements(with: environment) {
                    XCTContext.runActivity(named: "Scenario: \(scenario.title)") { _ in
                        BeforeScenario?(scenario)
                        for step in scenario.steps {
                            BeforeStep?(step)
                            currentStep = step
                            _ = XCTContext.runActivity(named: "\(step.keyword.toString()) \(step.match)") { _ -> String in
                                step.execute?(step.match.matches(for: step.regex), step)
                                if (step.execute != nil && step.result != .failed) {
                                    step.result = .passed
                                }
                                return ""
                            }
                            AfterStep?(step)
                        }
                        AfterScenario?(scenario)
                    }
                }
                AfterFeature?(feature)
            }
        }
        DispatchQueue.main.async {
            if  let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false),
                let data = try? JSONSerialization.data(withJSONObject: self.features.map { $0.toJSON() }, options: JSONSerialization.WritingOptions.prettyPrinted) {
                let fileURL = documentDirectory.appendingPathComponent(self.reportName)
                try? data.write(to: fileURL)
            }
        }
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
    
    public func Given(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
        attachClosureToSteps(keyword: .given, regex: regex, callback:callback)
    }
    public func When(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
        attachClosureToSteps(keyword: .when, regex: regex, callback:callback)
    }
    public func Then(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
        attachClosureToSteps(keyword: .then, regex: regex, callback:callback)
    }
    public func And(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
        attachClosureToSteps(keyword: .and, regex: regex, callback:callback)
    }
    public func But(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
        attachClosureToSteps(keyword: .but, regex: regex, callback:callback)
    }
    public func MatchAll(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
        attachClosureToSteps(regex: regex, callback:callback)
    }
    
}

public func Given(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
    Cucumber.shared.attachClosureToSteps(keyword: .given, regex: regex, callback:callback)
}
public func When(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
    Cucumber.shared.attachClosureToSteps(keyword: .when, regex: regex, callback:callback)
}
public func Then(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
    Cucumber.shared.attachClosureToSteps(keyword: .then, regex: regex, callback:callback)
}
public func And(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
    Cucumber.shared.attachClosureToSteps(keyword: .and, regex: regex, callback:callback)
}
public func But(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
    Cucumber.shared.attachClosureToSteps(keyword: .but, regex: regex, callback:callback)
}
public func MatchAll(_ regex:String, callback:@escaping (([String], Step) -> Void)) {
    Cucumber.shared.attachClosureToSteps(regex: regex, callback:callback)
}
