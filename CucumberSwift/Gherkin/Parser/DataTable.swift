//
//  DataTable.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 7/22/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
public class DataTable {
    public typealias Row = [String]
    var rows = [Row]()
    init(_ lines:[Row]) {
        rows = lines
    }
}
