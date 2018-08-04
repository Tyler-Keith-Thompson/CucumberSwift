### CucumberSwift
CucumberSwift is a lightweight, swift-only Cucumber implementation. It was born out of frustration with current iOS Cucumber implementations. Because it's written in swift you avoid any bridging header frustration and it provides more feature, scenario and step hooks than other solutions.

CucumberSwift also has the advantage of letting you choose where and how steps are associated with files. For example, you can initialize Cucumber with a directory, then provide step definitions, or a file, then provide step definitions. This makes separation of UI, Service-Layer, and Unit tests much easier. It also allows you to use the same language based off of the context of a feature without getting a regex collision (BDD purists may argue this is a bad thing)

### Installation
##### Cocoapods
Add this line to your podfile:
```ruby
    pod 'CucumberSwift'
```

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
        cucumber.Given("Something (matches|matched)") { (matches, _) in
            //assuming match is "Something matched"
            print(matches[0]) //Something matched
            print(matches[1]) //matched
        }

        cucumber.When("Something (matches|matched)") { (matches, _) in
            //assuming match is "Something matched"
            print(matches[0]) //Something matched
            print(matches[1]) //matched
        }

        cucumber.Then("Something (matches|matched)") { (matches, _) in
            //assuming match is "Something matched"
            print(matches[0]) //Something matched
            print(matches[1]) //matched
        }

        cucumber.And("Something (matches|matched)") { (matches, _) in
            //assuming match is "Something matched"
            print(matches[0]) //Something matched
            print(matches[1]) //matched
        }

        cucumber.But("Something (matches|matched)") { (matches, _) in
            //assuming match is "Something matched"
            print(matches[0]) //Something matched
            print(matches[1]) //matched
        }

        cucumber.MatchAll("Something (matches|matched)") { (matches, _) in
            //assuming match is "Something matched"
            print(matches[0]) //Something matched
            print(matches[1]) //matched
        }

        cucumber.executeFeatures()
    }
    
}
```

### Generated step stubs
Writing regex can be a pain, rather than make you look up everything CucumberSwift will help you out by generating swift code with stubs for step definitions

![image](https://github.com/Tyler-Keith-Thompson/CucumberSwift/blob/master/CucumberSwift-Generated-Steps.gif)

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

### Tags
You can specify what tags are supposed to be run by using the environment variable `CUCUMBER_TAGS`. This can be set by going to edit scheme -> test -> environment variables. Pass in a comma delimited list of tags to run.

### Data Tables
There are two categories of data table, one of them is in a scenario outline

#### Examples:
Examples let gherkin handle the data for you, individual scenarios are created that iterate over the table and inject the values
```gherkin
Feature: Some terse yet descriptive text of what is desired
        
    Background:
        Given I am logged in
    
    Scenario Outline: <user> logs in # 1st: Dave, 2nd: Bob
        Given a user named <user> # 1st: Dave, 2nd: Bob
            And a password <password> # 1st: hello, 2nd: *%&#*#!!
        When <user> logs in # 1st: Dave, 2nd: Bob
        Then <user> sees <account balance> # 1st: $0, 2nd: $20,000

        Examples:
            | user  | password | account balance |
            | Dave  | hello    | $0              |
            | Bob   | *%&#*#!! | $20,000         |
```

#### Test Data:
Test data can be attached to a step and is handed off to the step implementation to deal with.
```gherkin
    Feature: Some terse yet descriptive text of what is desired
        Scenario: minimalistic
            Given a simple data table
            | foo | bar |
            | boz | boo |
```
This can be accessed with CucumberSwift with an optional dataTable property on the step object
```swift
import Foundation
import XCTest
import CucumberSwift

class MyBehaviorTests: XCTestCase {

    func testBehavior() {
        let bundle = Bundle(for: MyBehaviorTests.self)
        let cucumber = Cucumber(withDirectory:"Features", inBundle: bundle)
        cucumber.Given("^a simple data table$") { (_, step) in
            let dt = step.dataTable!
            let row = dt.rows[0]
            print(row[0]) //foo
            print(row[1]) //bar
        }
        cucumber.executeFeatures()
    }
    
}
```

### What's Still Missing?
- Gherkin language errors
- Rules
- Docstrings
- AND support for tags (currently when multiple tags are passed in it's treated as OR)

### When will it be done?
The gherkin language features mentioned above will be completed as I've got time to work on it. If you want to see something feel free to submit a pull request