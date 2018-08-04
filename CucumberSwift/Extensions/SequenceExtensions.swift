//
//  SequenceExtensions.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/4/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
extension Sequence where Iterator.Element: Equatable {
    var uniqueElements: [Iterator.Element] {
        return self.reduce(into: []) {
            if (!$0.contains($1)) {
                $0.append($1)
            }
        }
    }
    mutating func removeDuplicates() {
        self ?= uniqueElements as? Self
    }
}
