//
//  CucumberTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 7/21/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest
@testable import CucumberSwift

class CucumberTests:XCTestCase {
    typealias TestType = (feature:String, ast:String)
    
    func testGoodExamples() {
        var tests:[String:TestType] = [:]
        let bundle = Bundle(for: CucumberTests.self)
        let enumerator:FileManager.DirectoryEnumerator? = FileManager.default.enumerator(at: bundle.bundleURL.appendingPathComponent("testdata/good"), includingPropertiesForKeys: nil)
        while let url = enumerator?.nextObject() as? URL {
            if (url.absoluteString.hasSuffix(".feature")) {
                if let string = try? String(contentsOf: url, encoding: .utf8) {
                    let name = url.absoluteString.components(separatedBy: ".feature").first!
                    var test:TestType = tests[name] ?? ("", "")
                    test.feature = string
                    tests[name] = test
                }
            } else if (url.absoluteString.hasSuffix(".feature.ast.ndjson")) {
                if let string = try? String(contentsOf: url, encoding: .utf8) {
                    let name = url.absoluteString.components(separatedBy: ".feature.ast.ndjson").first!
                    var test:TestType = tests[name] ?? ("", "")
                    test.ast = string
                    tests[name] = test
                }
            }
        }
        tests.forEach { (name, test) in
            guard !name.contains("rule") else { return }
            let tokens = Lexer(test.feature, uri: "test.feature").lex()
            let ast = AST(tokens)
            if  let data = test.ast.data(using: .utf8),
                let expectedAST = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any],
                let document = expectedAST?["gherkinDocument"] as? [String:Any] {
                if let feature = document["feature"] as? [String:Any] {
                    guard let featureNode = ast.featureNodes.first else { XCTFail("Should have been a feature in \(name)");return }
                    let featureObj = Feature(with: featureNode)
                    if let name = feature["name"] as? String {
                        XCTAssertEqual(name, featureObj.title)
                    }
                    if let children = feature["children"] as? [[String:Any]] {
                        XCTAssertEqual(featureNode.children.count, children.count, "Wrong number of children in \(name)")
                        for (childIndex, child) in children.enumerated() {
                            let node = featureNode.children[safe: childIndex]
                            if let background = child["background"] as? [String:Any] {
                                guard let backgroundNode = node as? BackgroundNode else { XCTFail("No background node found");return }
                                let backgroundSteps:[Step] = backgroundNode.children.compactMap { $0 as? StepNode }.map { Step(with: $0) }
                                if let steps = background["steps"] as? [[String:Any]] {
                                    XCTAssertEqual(steps.count, backgroundSteps.count, "Background step count is not the same")
                                    for (i, step) in steps.enumerated() {
                                        let backgroundStep = backgroundSteps[safe: i]
                                        if let keyword = step["keyword"] as? String {
                                            if (keyword.trimmingCharacters(in: .whitespaces) == "*") { return }
                                            XCTAssertEqual(keyword.trimmingCharacters(in: .whitespaces), backgroundStep?.keyword.toString())
                                        }
                                        if let text = step["text"] as? String {
                                            XCTAssertEqual(text, backgroundStep?.match)
                                        }
                                    }
                                }
                            }
//                            if let scenario = child["scenario"] as? [String:Any] {
//                                guard let scenarioNode = node as? ScenarioNode else { XCTFail("No scenario node found in file: \(name)");return }
//                                let scenarioSteps:[Step] = scenarioNode.children.compactMap { $0 as? StepNode }.map { Step(with: $0) }
//                                if let steps = scenario["steps"] as? [[String:Any]] {
//                                    XCTAssertEqual(steps.count, scenarioSteps.count, "Scenario step count is not the same")
//                                    for (i, step) in steps.enumerated() {
//                                        let scenarioStep = scenarioSteps[safe: i]
//                                        if let keyword = step["keyword"] as? String {
//                                            if (keyword.trimmingCharacters(in: .whitespaces) == "*") { return }
//                                            XCTAssertEqual(keyword.trimmingCharacters(in: .whitespaces), scenarioStep?.keyword.toString())
//                                        }
//                                        if let text = step["text"] as? String {
//                                            XCTAssertEqual(text, scenarioStep?.match)
//                                        }
//                                    }
//                                }
//                            }
                        }
                    }
                }
            }
        }
    }
}
