//
//  CucumberExtensions.swift
//  CucumberSwiftTests
//
//  Created by Tyler Thompson on 3/2/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation
@testable import CucumberSwift

extension Cucumber {
    func executeFeatures() {
        generateUnimplementedStepDefinitions()
        features.taggedElements(with: environment, askImplementor: false)
            .flatMap{ $0.scenarios.taggedElements(with: environment, askImplementor: true) }
            .flatMap{ $0.steps }
            .forEach{ $0.execute?($0.match.matches(for: $0.regex), $0)}
    }
}

