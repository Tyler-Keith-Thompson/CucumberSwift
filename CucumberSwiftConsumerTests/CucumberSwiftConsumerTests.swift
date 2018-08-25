//
//  CucumberSwiftConsumerTests.swift
//  CucumberSwiftConsumerTests
//
//  Created by Tyler Thompson on 8/25/18.
//  Copyright © 2018 Tyler Thompson. All rights reserved.
//

import XCTest
import CucumberSwift

class CucumberSwiftConsumerTests: CucumberTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Given("^I have a before feature hook$") { _, _ in
            
        }
        Given("^I have a scenario defined$") { _, _ in
            
        }
        When("^I run the tests$") { _, _ in
            
        }
        Then("^BeforeFeature gets called once per feature$") { _, _ in
            
        }
        Then("^The scenario runs without crashing$") { _, _ in
            
        }
        And("^The steps are slightly different$") { _, _ in
            
        }
    }
}
