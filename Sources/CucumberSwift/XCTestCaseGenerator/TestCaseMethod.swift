//
//  TestCaseMethod.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 3/2/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation

class TestCaseMethod {
    var name: UnsafePointer<Int8>
    var closure: @convention(block) () -> Void

    init?(withName name: String, closure: @escaping (() -> Void)) {
        // swiftlint:disable:next legacy_objc_type
        guard let utf8 = (name as NSString).utf8String else { return nil }
        self.name = utf8
        self.closure = closure
    }
}
