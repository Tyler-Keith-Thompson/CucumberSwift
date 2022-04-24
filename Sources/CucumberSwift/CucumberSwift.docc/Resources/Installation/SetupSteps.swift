import XCTest
import CucumberSwift

extension Cucumber: StepImplementation {
    public var bundle: Bundle {
        class Findme { }
        return Bundle(for: Findme.self) //This is just my shortcut way of identifying the test bundle, you do you. This bundle needs to contain the folder reference we added
    }

    public func setupSteps() {

    }
}
