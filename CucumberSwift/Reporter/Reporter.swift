//
//  Reporter.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 3/10/19.
//  Copyright © 2019 Tyler Thompson. All rights reserved.
//

import Foundation

class Reporter {
    static let shared = Reporter()
    var reportURL:URL? {
        let name = "_cucumberReport".appending(".json")
        if  let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false) {
            return documentDirectory.appendingPathComponent(name)
        }
        return nil
    }
    
    var currentJSON:[[String:Any]]? {
        guard let fileURL = reportURL,
              let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [[String:Any]]
    }
    
    func writeStep(_ step:Step) {
        guard let scenario = step.scenario,
            let (fIndex, scIndex) = writeScenarioIfNecessary(scenario),
            var features = currentJSON,
            features.count > fIndex else { return }
        let stepIndex = scenario.steps.enumerated().first { (_, s) -> Bool in
            return s === step
        }?.offset
        var featureJSON = features[fIndex]
        guard let sIndex = stepIndex,
              var elements = featureJSON["elements"] as? [[String:Any]],
              elements.count > scIndex else { return }
        var scenarioJSON = elements[scIndex]
        var steps = scenarioJSON["steps"] as? [[String:Any]] ?? []
        if steps.count-1 >= sIndex {
            steps[sIndex] = step.toJSON()
        } else {
            steps.append(step.toJSON())
        }
        scenarioJSON["steps"] = steps
        elements[scIndex] = scenarioJSON
        featureJSON["elements"] = elements
        features[fIndex] = featureJSON
        write(features)
    }
    
    @discardableResult func writeScenarioIfNecessary(_ scenario:Scenario) -> (featureIndex:Int, scenarioIndex:Int)? {
        guard let feature = scenario.feature else { return nil }
        let fIndex = writeFeatureIfNecessary(feature)
        guard var features = currentJSON,
              features.count > fIndex else { return nil }
        var featureJSON = features[fIndex]
        var elements = featureJSON["elements"] as? [[String:Any]] ?? []
        let scenarioIndex = feature.scenarios.enumerated().first { (_, s) -> Bool in
            return s === scenario
        }?.offset
        guard let sIndex = scenarioIndex else { return nil }
        if elements.count == sIndex {
            elements.append(scenario.toJSON())
        }
        featureJSON["elements"] = elements
        features[fIndex] = featureJSON
        write(features)
        return (featureIndex: fIndex, scenarioIndex: sIndex)
    }
    
    @discardableResult func writeFeatureIfNecessary(_ feature:Feature) -> Int {
        guard var features = currentJSON else {
            write([feature.toJSON()])
            return 0
        }
        let f = features.enumerated().first { (_, json) -> Bool in
            json["uri"] as? String == feature.uri
        }
        guard f?.element == nil else { return f!.offset }
        features.append(feature.toJSON())
        write(features)
        return 0
    }
    
    func write(_ dict:[[String:Any]]) {
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
              let fileURL = reportURL else {
            return
        }
        try? data.write(to: fileURL)
    }
    
    func reset() {
        guard let fileURL = reportURL else { return }
        try? FileManager.default.removeItem(at: fileURL)
    }
}
