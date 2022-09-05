# Matching Steps

Gherkin defined in `.feature` files can be matched in several ways. All matching is done using global functions that align with gherkin keywords. For example, ``Given``, ``When``, and ``Then`` functions. These functions are also localized, so if you'd rather use spanish you can use ``ES_Dado``. 

## Matching with Cucumber Expressions
Cucumber has [its own expressions](https://github.com/cucumber/cucumber-expressions#readme) that CucumberSwift supports. These are an alternative to regular expressions that are a little more readable. They aren't nearly as powerful when it comes to precise matching, but they can be extended with regular expressions and can very likely meet the majority of use-cases. Normally, Cucumber implementations use expressions by default in languages that have regular expression literals. However, because CucumberSwift was created long before Swift supported regex literals they are *not* the default.

Imagine the following step:
```gherkin
Given there are 3 flights from lax.
```

We could match it in CucumberSwift like this:
```swift
Given("there is/are/were {int} flight(s) from {airport}." as CucumberExpression) { match, _ in 
    XCTAssertEqual(match[\.int, index: 0], 3)
    XCTAssertEqual(try match.first(\.int), 3)
    XCTAssertEqual(try match.last(\.int), 3)
    XCTAssertEqual(try match.allParameters(\.int), [3])
    XCTAssertIdentical(match[\.airport, index: 0], Airport.lax)
    XCTAssertIdentical(try match.first(\.airport), Airport.lax)
    XCTAssertIdentical(try match.last(\.airport), Airport.lax)
    XCTAssertEqual(try match.allParameters(\.airport).count, 1)
    XCTAssertIdentical(try match.allParameters(\.airport).first, Airport.lax)
}
```

Notice that `{airport}` is a custom parameter. It's type-safe which is great, but how do we create our own custom parameters?

```swift
// Just an example of airports, this is simply your model.
class Airport {
    static let lax = Airport()
}

// This extension must contain all custom parameters you want to use.
extension CucumberExpression: CustomParameters {
    public static var additionalParameters: [CucumberSwiftExpressions.AnyParameter] {
        [
            AirportParameter().eraseToAnyParameter()
        ]
    }
}

// The airport parameter
struct AirportParameter: Parameter {
    enum ParameterError: Error {
        case airportNotFound
    }

    // Globally unique name for this parameter
    static let name = "airport"

    // A regular expression to use to match this parameter.
    let regexMatch = #"[A-Z]{3}"#

    // A transform from the matched string to whatever type you want
    func convert(input: String) throws -> Airport {
        switch input.lowercased() {
            case "lax": return Airport.lax
            default:
                throw ParameterError.airportNotFound
        }
    }
}

// A convenience property to use that keypath syntax you saw in the previous example.
extension Match {
    var airport: AirportParameter {
        AirportParameter()
    }
}
```

## Matching with Regular Expressions
Regular expressions are a very powerful tool. If you can support regex literals in your tests, they are by far the preferable method to match with.

Here's a trivial example:
```swift
When(/^some (\w+) by the actor$/.ignoresCase()) { match, _ in
    XCTAssertEqual(match.1, "action")
}
```

> NOTE: You can use regex builders in Swift to transform into concrete types. It's a little verbose, but is supported by CucumberSwift.
