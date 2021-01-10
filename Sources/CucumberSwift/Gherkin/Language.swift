//
//  Language.swift
//  CucumberSwift
//
//  Created by Tyler Thompson on 7/22/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import Foundation
class Language {
    struct Keys {
        static let feature = "feature"
        static let scenario = "scenario"
        static let background = "background"
        static let examples = "examples"
        static let scenarioOutline = "scenarioOutline"
        static let given = "given"
        static let when = "when"
        static let then = "then"
        static let and = "and"
        static let but = "but"
        static let rule = "rule"
    }
    
    private var featureNames = [String]()
    private var scenarioNames = [String]()
    private var backgroundNames = [String]()
    private var examplesNames = [String]()
    private var scenarioOutlineNames = [String]()
    private var ruleNames = [String()]
    private var givenNames = [String]()
    private var whenNames = [String]()
    private var thenNames = [String]()
    private var andNames = [String]()
    private var butNames = [String]()
    
    public var given:String {
        return givenNames.last?.capitalizingFirstLetter() ?? "Given"
    }
    public var when:String {
        return whenNames.last?.capitalizingFirstLetter() ?? "When"
    }
    public var then:String {
        return thenNames.last?.capitalizingFirstLetter() ?? "Then"
    }
    public var and:String {
        return andNames.last?.capitalizingFirstLetter() ?? "And"
    }
    public var but:String {
        return butNames.last?.capitalizingFirstLetter() ?? "But"
    }
    
    private init() { }

    init?(_ langName:String = "en") {
        let bundle = Bundle(for: Cucumber.self).resolvedForSPM
        if  let path = bundle.path(forResource: "gherkin-languages", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let json = jsonObject as? [String:Any],
            let language = json[langName] as? [String:Any] {
            featureNames         ?= (language[Keys.feature]         as? [String])?.map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            scenarioNames        ?= (language[Keys.scenario]        as? [String])?.map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            backgroundNames      ?= (language[Keys.background]      as? [String])?.map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            examplesNames        ?= (language[Keys.examples]        as? [String])?.map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            scenarioOutlineNames ?= (language[Keys.scenarioOutline] as? [String])?.map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            ruleNames            ?= (language[Keys.rule]            as? [String])?.map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            givenNames           ?= (language[Keys.given]           as? [String])?.map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            whenNames            ?= (language[Keys.when]            as? [String])?.map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            thenNames            ?= (language[Keys.then]            as? [String])?.map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            andNames             ?= (language[Keys.and]             as? [String])?.map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            butNames             ?= (language[Keys.but]             as? [String])?.map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        } else {
            return nil
        }
    }
    
    func matchesFeature(_ str:String) -> Bool {
        return featureNames
            .contains(where: { $0 == str.lowercased() })
    }
    
    func matchesScenario(_ str:String) -> Bool {
        return scenarioNames
            .contains(where: { $0 == str.lowercased() })
    }
    
    func matchesBackground(_ str:String) -> Bool {
        return backgroundNames
            .contains(where: { $0 == str.lowercased() })
    }
    
    func matchesExamples(_ str:String) -> Bool {
        return examplesNames
            .contains(where: { $0 == str.lowercased() })
    }
    
    func matchesScenarioOutline(_ str:String) -> Bool {
        return scenarioOutlineNames
            .contains(where: { $0 == str.lowercased() })
    }

    func matchesRule(_ str:String) -> Bool {
        return ruleNames
            .contains(where: { $0 == str.lowercased() })
    }

    func matchesGiven(_ str:String) -> Bool {
        return givenNames
            .contains(where: { $0 == str.lowercased() })
    }
    
    func matchesWhen(_ str:String) -> Bool {
        return whenNames
            .contains(where: { $0 == str.lowercased() })
    }
    
    func matchesThen(_ str:String) -> Bool {
        return thenNames
            .contains(where: { $0 == str.lowercased() })
    }
    
    func matchesAnd(_ str:String) -> Bool {
        return andNames
            .contains(where: { $0 == str.lowercased() })
    }
    
    func matchesBut(_ str:String) -> Bool {
        return butNames
            .contains(where: { $0 == str.lowercased() })
    }
}

extension Language {
    static var `default`:Language = {
        var l = Language()
        l.featureNames = ["Feature", "Business Need", "Ability"].map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        l.scenarioNames = ["Scenario", "Example"].map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        l.backgroundNames = ["Background"].map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        l.examplesNames = ["Examples", "Scenarios"].map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        l.ruleNames = ["Rule"].map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        l.scenarioOutlineNames = ["Scenario Outline", "Scenario Template"].map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        l.givenNames = ["* ", "Given "].map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        l.whenNames = ["* ", "When "].map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        l.thenNames = ["* ", "Then "].map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        l.andNames = ["* ", "And  "].map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        l.butNames = ["* ", "But "].map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
        return l
    }()
}
