import XCTest
import CucumberSwift

extension Cucumber: StepImplementation {
    public var bundle: Bundle {
        class TestExplorer: CucumberTest { } // !! Make sure to inherit from CucumberTest
        return Bundle(for: TestExplorer.self) // !! Important, this is what allows Cucumber Tests to be discovered.
    }

    public func setupSteps() {

    }
}
