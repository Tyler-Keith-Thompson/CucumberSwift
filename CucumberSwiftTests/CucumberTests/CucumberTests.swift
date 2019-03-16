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

extension Collection where Element == Token {
    public var text:String {
        return compactMap { (token) -> String? in
            switch token {
            case .integer(let t):
                return t
            case .string(let t):
                return t
            case .match(let t):
                return t
            case .tableHeader(let t):
                return "<\(t)>"
            default: return nil
            }
        }.joined()
    }
}

class CucumberTests:XCTestCase {
    
    typealias TestType = (feature:String, ast:String)
    
    private func getTests(atPath path: String) -> [String:TestType] {
        var tests:[String:TestType] = [:]
        let bundle = Bundle(for: CucumberTests.self)
        let enumerator:FileManager.DirectoryEnumerator? = FileManager.default.enumerator(at: bundle.bundleURL.appendingPathComponent(path), includingPropertiesForKeys: nil)
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
        return tests
    }
    
    private func testSteps(scope:[String:Any], stepObjects:[Step], fileName:String) {
        if let steps = scope["steps"] as? [[String:Any]] {
            XCTAssertEqual(steps.count, stepObjects.count, "Step count is not the same")
            for (stepIndex, step) in steps.enumerated() {
                let stepObject = stepObjects[safe: stepIndex]
                if let keyword = step["keyword"] as? String {
                    if (keyword.trimmingCharacters(in: .whitespaces) == "*") { return }
                    if (keyword.trimmingCharacters(in: .whitespaces) == "Gitt") {
                        XCTAssert(stepObject?.keyword == .given)
                        return
                    }
                    if (keyword.trimmingCharacters(in: .whitespaces) == "Når") {
                        XCTAssert(stepObject?.keyword == .when)
                        return
                    }
                    if (keyword.trimmingCharacters(in: .whitespaces) == "Så") {
                        XCTAssert(stepObject?.keyword == .then)
                        return
                    }
                    XCTAssertEqual(keyword.trimmingCharacters(in: .whitespaces), stepObject?.keyword.toString())
                }
                if let text = step["text"] as? String {
                    XCTAssertEqual(text, stepObject?.tokens.text, "Text does not match in: \(fileName)")
                }
                if let dataTable = step["dataTable"] as? [String:Any],
                    let rows = dataTable["rows"] as? [[String:Any]] {
                    guard let dataTable = stepObject?.dataTable else { XCTFail("Step does not have a datatable"); return }
                    XCTAssertEqual(dataTable.rows.count, rows.count, "Rows don't match in: \(fileName)")
                    for (rowIndex, row) in rows.enumerated() {
                        let dRow = dataTable.rows[safe: rowIndex]
                        if let cells = row["cells"] as? [[String:Any]] {
                            XCTAssertEqual(dRow?.count, cells.count, "Row on DataTable doesn't have correct cells in: \(fileName)")
                            for (cellIndex, cell) in cells.enumerated() {
                                if let value = cell["value"] as? String {
                                    XCTAssertEqual(value, dRow?[safe: cellIndex])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func testGoodExamples() {
        let tests:[String:TestType] = getTests(atPath: "testdata/good")

        tests.forEach { (name, test) in
            guard !name.contains("rule"),
                !name.contains("Tags/tags"),
                !name.contains("EscapedPipes/escaped_pipes") else { return }
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
                                testSteps(scope: background, stepObjects: backgroundSteps, fileName: name)
                            }
                            if let scenario = child["scenario"] as? [String:Any] {
                                guard let scenarioType = scenario["keyword"] as? String else { return }
                                if (scenarioType == "Scenario") {
                                    guard let scenarioNode = node as? ScenarioNode else { XCTFail("No scenario node found in file: \(name)");return }
                                    let scenarioSteps:[Step] = scenarioNode.children.compactMap { $0 as? StepNode }.map { Step(with: $0) }
                                    testSteps(scope: scenario, stepObjects: scenarioSteps, fileName: name)
                                } else if (scenarioType == "Scenario Outline") {
                                    guard let scenarioNode = node as? ScenarioOutlineNode else { XCTFail("No scenario node found in file: \(name)");return }
                                    let scenarioSteps:[Step] = scenarioNode.children.compactMap { $0 as? StepNode }.map { Step(with: $0) }
                                    testSteps(scope: scenario, stepObjects: scenarioSteps, fileName: name)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
