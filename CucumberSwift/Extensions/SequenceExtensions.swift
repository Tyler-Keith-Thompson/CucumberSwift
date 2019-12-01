//
//  SequenceExtensions.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 8/4/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
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

extension Array {
    @inlinable public func dropFirst(_ k: Int = 1, predicate: ((Iterator.Element) throws -> Bool)) rethrows -> Self {
        var new = self
        var count = k
        while (count > 0) {
            count -= 1
            guard let first = new.first else { break }
            if (try predicate(first)) {
                new = Array<Iterator.Element>(new.dropFirst())
            } else {
                break
            }
        }
        return new
    }
    
    @inlinable public func dropLast(_ k: Int = 1, predicate: ((Iterator.Element) throws -> Bool)) rethrows -> Self {
        var new = self
        var count = k
        while (count > 0) {
            count -= 1
            guard let last = new.last else { break }
            if (try predicate(last)) {
                new = Array<Iterator.Element>(new.dropLast())
            } else {
                break
            }
        }
        return new
    }
}
