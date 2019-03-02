//
//  TestCaseGenerator.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 3/2/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
import XCTest

class TestCaseGenerator {
    static func initWith(className:String, method:TestCaseMethod?) -> XCTestCase? {
        guard let className = (className as NSString).utf8String,
              let method = method else { return nil }
        let testCase = objc_allocateClassPair(XCTestCase.self, className, 0) as? XCTestCase.Type
        let methodSelector = sel_registerName(method.name)
        let implementation = imp_implementationWithBlock(method.closure)
        class_addMethod(testCase, methodSelector, implementation, "v@:")
        return testCase?.init(selector: methodSelector)
    }
}
