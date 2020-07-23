//
//  StepBuilder.swift
//  CucumberSwift
//
//  Created by thompsty on 7/23/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation
@_functionBuilder
struct StepBuilder {
    static func buildBlock(_ items: Step?...) -> [Step] {
        return items.compactMap { $0 }
    }
}
