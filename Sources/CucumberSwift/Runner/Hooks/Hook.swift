//
//  Hook.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/24/21.
//  Copyright © 2021 Tyler Thompson. All rights reserved.
//

import Foundation

class Hook<T> {
    var priority: UInt?
    var hook: (T) -> Void

    init(priority: UInt?, hook: @escaping (T) -> Void) {
        self.priority = priority
        self.hook = hook
    }
}

extension Hook: Comparable {
    static func < (lhs: Hook<T>, rhs: Hook<T>) -> Bool {
        guard let lhsPriority = lhs.priority else { return false }
        guard let rhsPriority = rhs.priority else { return true }
        return lhsPriority < rhsPriority
    }

    static func == (lhs: Hook<T>, rhs: Hook<T>) -> Bool {
        lhs.priority == rhs.priority
    }
}
