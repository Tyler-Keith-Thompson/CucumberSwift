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
var beforeScenarioHooks = [Scenario:Int]()
var beforeStepHooks = [Step:Int]()
var afterStepHooks = [Step:Int]()
var afterScenarioHooks = [Scenario:Int]()
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
            beforeScenarioHooks[scenario, default: 0] += 1
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
            if (afterScenarioHooks[scenario] != nil) {
                XCTFail("Should not have the same after hook called")
            }
            afterScenarioHooks[scenario, default: 0] += 1
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
//                Given I have a before feature hook
                When(I: runTheTests())
//                Then BeforeFeature gets called once per feature
            }
            
            ScenarioOutline("Before <scn> hook works correctly", headers: String.self, steps: { scn in
//                Given I have a before <scn> hook
                When(I: runTheTests())
//                Then BeforeScenario gets called once per scenario
            }, examples: {
                [
                    "scenario outline"
                ]
            })
            
            Scenario("Before scenario outline hook works correctly") {
//                Given I have a before scenario hook
                When(I: runTheTests())
//                Then BeforeScenario gets called once per scenario outline
            }
            //NOTE: The preceding scenario is purposely meant to have a name collision, so it does not appropriate read what it is testing.
            
            Scenario("Before step hook works correctly") {
//                Given I have a before step hook
                When(I: runTheTests())
//                Then BeforeStep gets called once per step
            }
            
            Scenario("After step hook works correctly") {
//                Given I have an after step hook
                When(I: runTheTests())
//                Then AfterStep gets called once per step
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
            
            Scenario("Scenario with a step with a data table") {
                Given(I: XCTAssert(true))
//                Given I have some data table that is not implemented
//                    | tbl |
//                    | foo |
//                When I look in my test report
//                Then I see some PENDING steps with a swift attachment
//                    And I can copy and paste the swift code into my test case
            }
        }
    }
}

fileprivate func haveAScenarioDefined() { }
fileprivate func theStepsAreSlightlyDifferent() { }

fileprivate func runTheTests() {
    XCTAssert(true) // the tests are clearly running
}

fileprivate func scenarioRunsWithoutCrashing() {
    XCTAssert(true) // did not crash if it executes this
}

/* STUFF THAT IS NOT COVERED SO FAR
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
