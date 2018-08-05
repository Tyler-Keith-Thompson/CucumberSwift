//
//  Taggable.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 5/13/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
public protocol Taggable {
    var tags:[String] { get }
    func containsTags(_ tags:[String]) -> Bool
}
extension Taggable {
    func containsTag(_ tag:String) -> Bool {
        return tags.contains { !$0.matches(for: tag).isEmpty }
    }
}

extension Array where Element : Taggable {
    func taggedElements(with environment:[String:String] = ProcessInfo.processInfo.environment) -> [Element] {
        if let tagNames = environment["CUCUMBER_TAGS"] {
            let tags = tagNames.components(separatedBy: ",")
            return filter { $0.containsTags(tags) }
        }
        return self
    }
}
