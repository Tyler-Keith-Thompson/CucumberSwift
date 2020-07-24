//
//  ScenarioBuilder.swift
//  CucumberSwift
//
//  Created by thompsty on 7/23/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation

@_functionBuilder
public struct ScenarioBuilder {
    public static func buildBlock(_ items: Scenario?...) -> [Scenario] {
        return items.compactMap { $0 }
    }
}
