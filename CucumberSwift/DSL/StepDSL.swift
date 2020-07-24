//
//  StepDSL.swift
//  CucumberSwift
//
//  Created by thompsty on 7/23/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import Foundation

public class DSLStep: Step {
    public init() {
        super.init(with: AST.StepNode())
    }
    
    public init(line:UInt, column: UInt, match:String?, handler: @escaping () -> Void) {
        super.init(with: {_, _ in handler() }, match: match, position: Lexer.Position(line: line, column: column))
    }
    
    public func continueAfterFailure(_ val:Bool) -> DSLStep {
        continueAfterFailure = val
        return self
    }
}

public final class GivenStep: DSLStep, Matcher, GherkinDSL {
    public override var keyword: Step.Keyword { .given }
}

public final class WhenStep: DSLStep, Matcher, GherkinDSL {
    public override var keyword: Step.Keyword { .when }
}

public final class ThenStep: DSLStep, Matcher, GherkinDSL {
    public override var keyword: Step.Keyword { .then }
}

public final class AndStep: DSLStep, Matcher, GherkinDSL {
    public override var keyword: Step.Keyword { .and }
}

public final class ButStep: DSLStep, Matcher, GherkinDSL {
    public override var keyword: Step.Keyword { .but }
}

public final class MatchAllStep: DSLStep, Matcher, GherkinDSL {
    public override var keyword: Step.Keyword { [] }
}

public typealias Given = GivenStep
public typealias When = WhenStep
public typealias Then = ThenStep
public typealias And = AndStep
public typealias But = ButStep
public typealias MatchAll = MatchAllStep
