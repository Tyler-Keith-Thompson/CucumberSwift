import XCTest
@testable import CucumberSwift
class MightEqualOperatorTests: XCTestCase {
    func testMightEqualSetsOldStringToNewStringIfNewStringIsDefined() {
        var oldString = ""
        let newString = "I am a string!"
        oldString ?= newString
        XCTAssertEqual(oldString, newString, "String \"\" should be updated with the new value of \"\(newString)\"")
    }

    func testMightEqualDoesNotSetOldStringToNewStringIfNewStringIsNotDefined() {
        var oldString = "I used to be a string"
        oldString ?= nil
        XCTAssertEqual(oldString, "I used to be a string", "String \"I used to be a string\" should not be updated with nil")
    }
}
