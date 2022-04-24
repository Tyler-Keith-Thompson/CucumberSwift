import XCTest
import CucumberSwift

extension Cucumber: StepImplementation {
    public var bundle: Bundle { /* ... */ }

    public func setupSteps() {
        Given("^CucumberSwift is setup correctly$") { _, _ in

        }
        When("^I execute these tests$") { _, _ in

        }
        Then("^I can pull generated code from the report explorer and get things set up$") { _, _ in

        }
    }
}
