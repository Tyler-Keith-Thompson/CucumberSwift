### CucumberSwift
CucumberSwift is a lightweight, swift-only Cucumber implementation. It was born out of frustration with current iOS Cucumber implementations (XCFit, Cucumberish). Because it's written in swift you avoid the bridging header frustration of Cucumberish and it provides more feature, scenario and step hooks than other solutions.

CucumberSwift also has the advantage of letting you choose where and how steps are associated with files. For example, you can initialize Cucumber with a directory, then provide step definitions, or a file, then provide step definitions. This makes separation of UI, Service-Layer, and Unit tests much easier. It also allows you to use the same language based off of the context of a feature without getting a regex collision (BDD purists may argue this is a bad thing)

### Installation
##### Cocoapods
Add this line to your podfile:
```ruby
    pod 'CucumberSwift', :git => 'https://github.com/Tyler-Keith-Thompson/CucumberSwift.git'
```

### What's Missing?

- Background definition
- Gherkin Tables
- Tags
- Inline comments