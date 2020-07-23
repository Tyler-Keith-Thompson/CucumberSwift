//
//  StepDSL.swift
//  CucumberSwift
//
//  Created by thompsty on 7/23/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation

public final class GivenStep: Step, Matcher, GherkinDSL {
    public init() { super.init(with: AST.StepNode()) }
    public override var keyword: Step.Keyword {
        .given
    }
}

public final class WhenStep: Step, Matcher, GherkinDSL {
    public init() { super.init(with: AST.StepNode()) }
    public override var keyword: Step.Keyword {
        .when
    }
}
public final class ThenStep: Step, Matcher, GherkinDSL {
    public init() { super.init(with: AST.StepNode()) }
    public override var keyword: Step.Keyword {
        .then
    }
}
public final class AndStep: Step, Matcher, GherkinDSL {
    public init() { super.init(with: AST.StepNode()) }
    public override var keyword: Step.Keyword {
        .and
    }
}
public final class ButStep: Step, Matcher, GherkinDSL {
    public init() { super.init(with: AST.StepNode()) }
    public override var keyword: Step.Keyword {
        .but
    }
}
public final class MatchAllStep: Step, Matcher, GherkinDSL {
    public init() { super.init(with: AST.StepNode()) }
    public override var keyword: Step.Keyword {
        []
    }
}

public typealias Given = GivenStep
public typealias When = WhenStep
public typealias Then = ThenStep
public typealias And = AndStep
public typealias But = ButStep
public typealias MatchAll = MatchAllStep
