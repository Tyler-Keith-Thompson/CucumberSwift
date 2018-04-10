### CucumberSwift
CucumberSwift is a lightweight, swift-only Cucumber implementation. It was born out of frustration with current iOS Cucumber implementations (XCFit, Cucumberish). Because it's written in swift you avoid the bridging header frustration of Cucumberish and it provides more feature, scenario and step hooks than other solutions.

CucumberSwift also has the advantage of letting you choose where and how steps are associated with files. For example, you can initialize Cucumber with a directory, then provide step definitions, or a file, then provide step definitions. This makes separation of UI, Service-Layer, and Unit tests much easier. It also allows you to use the same language based off of the context of a feature without getting a regex collision (BDD purists may argue this is a bad thing)

### Installation
##### Cocoapods
Add this line to your podfile:
```ruby
    pod 'CucumberSwift'
```

### What's Missing?

- Gherkin Tables
- Tags
- inline comments

### How do I use it?
CucumberSwift can be used inside any class any way you like, the preffered method would be to stick it in a subclass of XCTestCase.
```swift
import Foundation
import XCTest
import CucumberSwift

class MyBehaviorTests: XCTestCase {

    func testBehavior() {
        let bundle = Bundle(for: MyBehaviorTests.self)
        let cucumber = Cucumber(withDirectory:"Features", inBundle: bundle)
        //Step definitions
        cucumber.Given("Something (matches|matched)") {  matches in
            
        }

        cucumber.When("Something (matches|matched)") {  matches in
            
        }

        cucumber.Then("Something (matches|matched)") {  matches in
            
        }

        cucumber.And("Something (matches|matched)") {  matches in
            
        }

        cucumber.Or("Something (matches|matched)") {  matches in
            
        }

        cucumber.But("Something (matches|matched)") {  matches in
            
        }

        cucumber.MatchAll("Something (matches|matched)") {  matches in
            
        }

        cucumber.executeFeatures()
    }
    
}
```

### Hooks
CucumberSwift comes with 6 hooks, Before/After Feature Before/After Scenario and Before/After step, use them like so
```swift
import Foundation
import XCTest
import CucumberSwift

class MyBehaviorTests: XCTestCase {

    func testBehavior() {
        let bundle = Bundle(for: MyBehaviorTests.self)
        let cucumber = Cucumber(withDirectory:"Features", inBundle: bundle)
        //hooks
        cucumber.BeforeFeature = { feature in

        }
        
        cucumber.AfterFeature = { feature in
            
        }
        
        cucumber.BeforeScenario = { scenario in
            
        }

        cucumber.AfterScenario = { scenario in
            
        }

        cucumber.BeforeStep = { step in
            
        }

        cucumber.AfterStep = { step in
            
        }
        cucumber.executeFeatures()
    }
    
}
```