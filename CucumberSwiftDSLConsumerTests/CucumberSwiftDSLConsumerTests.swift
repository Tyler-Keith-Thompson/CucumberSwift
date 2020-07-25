//
//  CucumberSwiftDSLConsumerTests.swift
//  CucumberSwiftDSLConsumerTests
//
//  Created by thompsty on 7/24/20.
//  Copyright © 2020 Tyler Thompson. All rights reserved.
//

import XCTest
import CucumberSwift


//nothin' like global vars!
var beforeFeatureHooks = [Feature:Int]()
var secondaryBeforeFeatureHooks = [Feature:Int]()
var beforeScenarioHooks = [String:Int]()
var beforeStepHooks = [Step:Int]()
var afterStepHooks = [Step:Int]()
var afterScenarioHooks = [String:Int]()
var afterFeatureHooks = [Feature:Int]()

extension Cucumber: StepImplementation {
    public var bundle: Bundle {
        class Findme { }
        return Bundle(for: Findme.self)
    }

    func setupHooks() {
        BeforeFeature { feature in
            beforeFeatureHooks[feature, default: 0] += 1
        }
        BeforeFeature { feature in
            secondaryBeforeFeatureHooks[feature, default: 0] += 1
        }
        BeforeScenario { scenario in
            beforeScenarioHooks[scenario.title, default: 0] += 1
        }
        BeforeStep { step in
            beforeStepHooks[step, default: 0] += 1
        }
        AfterStep { step in
            if (afterStepHooks[step] != nil) {
                XCTFail("Should not have the same after hook called")
            }
            afterStepHooks[step, default: 0] += 1
        }
        AfterScenario { scenario in
            afterScenarioHooks[scenario.title, default: 0] += 1
        }
        AfterFeature { feature in
            if (afterFeatureHooks[feature] != nil) {
                XCTFail("Should not have the same after hook called")
            }
            afterFeatureHooks[feature, default: 0] += 1
        }
    }
    
    public func setupSteps() {
        setupHooks()
        Feature("CucumberSwift Library") {
            Description("""
                The CucumberSwift library needs to work like Developers, QAs and Product Owners expect it to
                This particular test pulls in the library much like they would and ensures it behaves
                as expected
            """)
            
            Scenario("Before feature hook works correctly") {
                Given(I: haveABeforeFeatureHook())
                When(I: runTheTests())
                Then(beforeFeatureGetsCalledOncePerFeature())
            }
            
            //How do we make the title work correctly? Not sure, maybe a closure?
            ScenarioOutline({ "Before \($0) hook works correctly" }, headers: String.self, steps: { scn in
                Given(I: haveABeforeScenarioHook())
                When(I: runTheTests())
                Then(beforeScenarioGetsCalledOncePerScenario(withTitle: "Before scenario outline hook works correctly"))
            }, examples: {
                [
                    "scenario outline"
                ]
            })
            
            Scenario("Before scenario outline hook works correctly") {
                Given(I: haveABeforeScenarioHook())
                When(I: runTheTests())
                Then(beforeScenarioGetsCalledOncePerScenario(withTitle: "Before scenario outline hook works correctly", expected: 2))
            }
            //NOTE: The preceding scenario is purposely meant to have a name collision, so it does not appropriate read what it is testing.
            
            Scenario("Before step hook works correctly") {
                Given(I: haveABeforeStepHook())
                When(I: runTheTests())
                Then(beforeStepGetsCalledOncePerStep())
            }
            
            Scenario("After step hook works correctly") {
                Given(I: haveAnAfterStepHook())
                When(I: runTheTests())
                Then(afterStepGetsCalledOncePerStep())
            }
            
            Scenario("Scenario with the same name does not collide") {
                Given(I: haveAScenarioDefined())
                When(I: runTheTests())
                Then(the: scenarioRunsWithoutCrashing())
            }
            
            Scenario("Scenario with the same name does not collide") {
                Given(I: haveAScenarioDefined())
                    And(the: theStepsAreSlightlyDifferent())
                When(I: runTheTests())
                Then(the: scenarioRunsWithoutCrashing())
            }
            
        }
    }
}

fileprivate func haveAScenarioDefined() { }
fileprivate func theStepsAreSlightlyDifferent() { }
fileprivate func haveABeforeFeatureHook() {
    XCTAssert(true) //yup, it happens in setupHooks
}
fileprivate func haveABeforeScenarioHook() {
    XCTAssert(true) //yup, it happens in setupHooks
}
fileprivate func haveABeforeStepHook() {
    XCTAssert(true) //yup, it happens in setupHooks
}
fileprivate func haveAnAfterStepHook() {
    XCTAssert(true) //yup, it happens in setupHooks
}

fileprivate func beforeFeatureGetsCalledOncePerFeature() {
    XCTAssertEqual(beforeFeatureHooks.count, 1)
    beforeFeatureHooks.forEach {
        XCTAssertEqual($1, 1)
    }
    secondaryBeforeFeatureHooks.forEach {
        XCTAssertEqual($1, 1)
    }
}

fileprivate func beforeStepGetsCalledOncePerStep() {
    XCTAssertEqual(beforeStepHooks.filter { $1 > 0 }.count, 12)
}

fileprivate func afterStepGetsCalledOncePerStep() {
    XCTAssertEqual(afterStepHooks.filter { $1 > 0 }.count, 14)
}


fileprivate func beforeScenarioGetsCalledOncePerScenario(withTitle title:String, expected:Int = 1) {
    XCTAssertEqual(beforeScenarioHooks[title], expected)
}

fileprivate func runTheTests() {
    XCTAssert(true) // the tests are clearly running
}

fileprivate func scenarioRunsWithoutCrashing() {
    XCTAssert(true) // did not crash if it executes this
}

/* STUFF THAT IS NOT COVERED SO FAR
            Scenario("Scenario with a step with a data table") {
                Given(I: XCTAssert(true))
                  Given I have some data table that is not implemented
                        | tbl |
                        | foo |
                    When I look in my test report
                    Then I see some PENDING steps with a swift attachment
                        And I can copy and paste the swift code into my test case
            }

 
     Scenario: Unimplemented scenario with DocString
         Given a DocString of some kind that is not implemented
         """xml
         <foo>
             <bar />
         </foo>
         """
         When I look in my test report
         Then I see some PENDING steps with a swift attachment
             And I can copy and paste the swift code into my test case
 */

extension Feature : Hashable {
    public static func == (lhs: Feature, rhs: Feature) -> Bool {
        return lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(Unmanaged.passUnretained(self).toOpaque())
    }
}

extension Step : Hashable {
    public static func == (lhs: Step, rhs: Step) -> Bool {
        return lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(Unmanaged.passUnretained(self).toOpaque())
    }
}
