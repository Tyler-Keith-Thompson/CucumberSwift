//
//  StringExtensions.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 4/7/18.
//  Copyright © 2018 Asynchrony Labs. All rights reserved.
//

import Foundation
extension String {
    var lines:[String] {
        get {
            var lines = [String]()
            enumerateLines { (line, _) in
                lines.append(line)
            }
            return lines
        }
    }
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: .caseInsensitive)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            guard !results.isEmpty else { return [] }
            var matches = [String]()
            for i in 0..<results.first!.numberOfRanges {
                matches.append(String(self[Range(results.first!.range(at: i), in: self)!]))
            }
            return matches
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    func trimmingComments(_ commentString:String = "#") -> String {
        guard !starts(with: commentString) else { return "" }
        return components(separatedBy: commentString).first ?? self
    }
}
