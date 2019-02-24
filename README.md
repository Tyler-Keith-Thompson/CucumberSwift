### CucumberSwift
CucumberSwift is a lightweight Cucumber implementation for swift. It was born out of frustration with current iOS Cucumber implementations. The whole goal is to make it easy to install and easy to use, so please feel free to give feedback.

* [Installation](#installation)
* [How do I use it?](#how-do-i-use-it)
* [Generated step stubs](#generated-step-stubs)
* [Hooks](#hooks)
* [Tags](#tags)
* [Data Tables](#data-tables)

### Installation
#### Cocoapods
Add this line to your podfile:
```ruby
    pod 'CucumberSwift'
```

#### XCode
After you install CucumberSwift open the info.plist file of your **test** target. You'll want the set the `Principal Class` to `CucumberSwift.Cucumber`. If you prefer editing your plists from source it should look like this:
```xml
	<key>NSPrincipalClass</key>
	<string>CucumberSwift.Cucumber</string>
```

![image](https://github.com/Tyler-Keith-Thompson/CucumberSwift/blob/master/CucumberSetup.gif)


#### How to set up my gherkin
Drag and drop your `Features` folder into your **test** target. Please make sure to create a folder reference, not a group.

#### My folder isn't called "Features", what do I do?
Not to fear! Info.plist is here! Just set the `FeaturesPath` property to the relative path to your folder. (Defaults to: Features)

### How do I use it?
CucumberSwift is designed to be run with XCTest. To start implementing some step definitions extend Cucumber with the StepImplementation protocol.
```swift
import Foundation
import XCTest
import CucumberSwift

extension Cucumber: StepImplementation {
    public func setupSteps() {
        //Step definitions
        Given("Something (matches|matched)") { (matches, _) in
            //assuming match is "Something matched"
            print(matches[0]) //Something matched
            print(matches[1]) //matched
        }

        When("Something (matches|matched)") { (matches, _) in
            //assuming match is "Something matched"
            print(matches[0]) //Something matched
            print(matches[1]) //matched
        }

        Then("Something (matches|matched)") { (matches, _) in
            //assuming match is "Something matched"
            print(matches[0]) //Something matched
            print(matches[1]) //matched
        }

        And("Something (matches|matched)") { (matches, _) in
            //assuming match is "Something matched"
            print(matches[0]) //Something matched
            print(matches[1]) //matched
        }

        But("Something (matches|matched)") { (matches, _) in
            //assuming match is "Something matched"
            print(matches[0]) //Something matched
            print(matches[1]) //matched
        }

        MatchAll("Something (matches|matched)") { (matches, _) in
            //assuming match is "Something matched"
            print(matches[0]) //Something matched
            print(matches[1]) //matched
        }
    }
}
```

### Generated step stubs
Writing regex can be a pain, rather than make you look up everything CucumberSwift will help you out by generating swift code with stubs for step definitions. Take a look in your report navigator. Expand the last test run and, if there are any unimplemented steps you will see a class called `GenerateStubsIfNecessary`.

If you expand that you'll see a Pending Steps section. Finally expanding that is an attachment called `GENERATED_Unimplemented_Step_Definitions.swift`. Open this attachment and you can copy/paste the swift code directly out of it.

![image](https://github.com/Tyler-Keith-Thompson/CucumberSwift/blob/master/GenerateStubsExample.gif)

### Hooks
CucumberSwift comes with 6 hooks, Before/After Feature Before/After Scenario and Before/After step, use them like so

NOTE: Hooks can be setup in more than 1 place however each hook will only be called once
```swift
import Foundation
import XCTest
import CucumberSwift

extension Cucumber: StepImplementation {
    public func setupSteps() {
        BeforeFeature { feature in
            //called once before the feature, but can be setup in more than 1 file.
        }
        
        AfterFeature { feature in
            
        }
        
        BeforeScenario { scenario in
            
        }

        AfterScenario { scenario in
            
        }

        BeforeStep { step in
            
        }

        AfterStep = { step in
            
        }
    }
}
```

### Tags
You leverage Swift's own conditional logic to decide what tags you want to run. Simply use your current extension of Cucumber that conforms to StepImplementation and implement the following optional method
```swift
public func shouldRunWith(tags: [String]) -> Bool {
    return tags.contains("MyTag")
}
```

**NOTE:** If you use the legacy version of tagging (i.e. the environment variable listed below) the optional method *WILL NOT GET CALLED*. The environment variable wins out in order to support older versions of CucumberSwift.

##### LEGACY:
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

extension Cucumber: StepImplementation {
    public func setupSteps() {
        Given("^a simple data table$") { (_, step) in
            let dt = step.dataTable!
            let row = dt.rows[0]
            print(row[0]) //foo
            print(row[1]) //bar
        }
    }    
}
```

### What's Still Missing?
- Some Gherkin language errors
- Rules
- Docstrings
