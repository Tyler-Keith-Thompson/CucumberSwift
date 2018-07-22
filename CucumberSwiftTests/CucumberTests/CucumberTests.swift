//
//  CucumberTests.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 7/21/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
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
            let tokens = Lexer(input: test.feature).lex()
            let ast = AST(tokens)
            if  let data = test.ast.data(using: .utf8),
            let expectedAST = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any],
                let document = expectedAST?["gherkinDocument"] as? [String:Any] {
                if let feature = document["feature"] as? [String:Any] {
                    let featureNode = ast.featureNodes.first
                    XCTAssertNotNil(featureNode, "Should have been a feature in \(name)")
                    if let children = feature["children"] as? [[String:Any]] {
                        XCTAssertEqual(featureNode?.children.count, children.count, "Wrong number of children in \(name)")
                    }
                }
            }
        }
    }
}
