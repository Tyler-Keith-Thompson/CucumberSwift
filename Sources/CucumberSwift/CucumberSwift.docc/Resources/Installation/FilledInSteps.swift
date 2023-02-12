import XCTest
import CucumberSwift

extension Cucumber: StepImplementation {
    public var bundle: Bundle { /* ... */ }

    public func setupSteps() {
        Given("CucumberSwift is setup correctly") { _, _ in

        }
        When("I execute these tests") { _, _ in

        }
        Then("I can pull generated code with {string} from the report explorer and get things set up") { matches, _ in
            let string = matches[1] // matches[0] is the entire statement, matches[1] is the string "matches"
        }
    }
}
