import Testing
import Foundation
@testable import SamuraiLoggingFirebaseAnalytics

// MARK: - String.clipped(maxCharacters:)

@Suite("String.clipped(maxCharacters:)")
struct StringClippedTests {

    @Test("Returns string unchanged when shorter than limit", arguments: zip(
        ["hello", "", "hi"],
        [10, 5, 5]
    ))
    func shorterThanLimit(input: String, limit: Int) {
        #expect(input.clipped(maxCharacters: limit) == input)
    }

    @Test("Clips to exact character count")
    func clipsToLimit() {
        #expect("Hello, World!".clipped(maxCharacters: 5) == "Hello")
    }

    @Test("Returns empty string when limit is zero")
    func zeroLimit() {
        #expect("hello".clipped(maxCharacters: 0) == "")
    }
}

// MARK: - String.replaceSpacesWithUnderscores()

@Suite("String.replaceSpacesWithUnderscores()")
struct StringReplaceSpacesTests {

    @Test("Replaces a single space with underscore")
    func singleSpace() {
        #expect("hello world".replaceSpacesWithUnderscores() == "hello_world")
    }

    @Test("Replaces multiple spaces with underscores")
    func multipleSpaces() {
        #expect("a b c".replaceSpacesWithUnderscores() == "a_b_c")
    }

    @Test("Returns string unchanged when no spaces present")
    func noSpaces() {
        #expect("hello_world".replaceSpacesWithUnderscores() == "hello_world")
    }

    @Test("Returns empty string unchanged")
    func emptyString() {
        #expect("".replaceSpacesWithUnderscores() == "")
    }
}

// MARK: - String.clean(maxCharacters:)

@Suite("String.clean(maxCharacters:)")
struct StringCleanTests {

    @Test("Replaces spaces with underscores")
    func replacesSpaces() {
        #expect("hello world".clean(maxCharacters: 100) == "hello_world")
    }

    @Test("Clips at 40 characters regardless of maxCharacters parameter")
    func clipsAt40Regardless() {
        // NOTE: clean() hardcodes clipped(maxCharacters: 40), ignoring the passed parameter
        let input = String(repeating: "a", count: 50)
        #expect(input.clean(maxCharacters: 100).count == 40)
    }

    @Test("Leaves string unchanged when shorter than 40 characters")
    func withinLimit() {
        #expect("short".clean(maxCharacters: 10) == "short")
    }

    @Test("Both clips at 40 and replaces spaces")
    func clipsAndReplacesSpaces() {
        let input = String(repeating: "a ", count: 25) // 50 characters with spaces
        let result = input.clean(maxCharacters: 100)
        #expect(result.count <= 40)
        #expect(!result.contains(" "))
    }
}

// MARK: - String.convertToString(_:)

@Suite("String.convertToString(_:)")
struct StringConvertToStringTests {

    @Test("Returns the string itself")
    func fromString() {
        #expect(String.convertToString("hello") == "hello")
    }

    @Test("Converts Int to string", arguments: zip([0, 42, -1], ["0", "42", "-1"]))
    func fromInt(value: Int, expected: String) {
        #expect(String.convertToString(value) == expected)
    }

    @Test("Converts Double to string")
    func fromDouble() {
        #expect(String.convertToString(3.14 as Double) == "3.14")
    }

    @Test("Converts Float to string")
    func fromFloat() {
        #expect(String.convertToString(1.5 as Float) == "1.5")
    }

    @Test("Converts Bool to string", arguments: zip([true, false], ["true", "false"]))
    func fromBool(value: Bool, expected: String) {
        #expect(String.convertToString(value) == expected)
    }

    @Test("Converts Date to a non-nil formatted string")
    func fromDate() {
        #expect(String.convertToString(Date()) != nil)
    }

    @Test("Converts array to a sorted, comma-joined string")
    func fromArray() {
        let result = String.convertToString(["banana", "apple", "cherry"] as [Any])
        #expect(result == "apple, banana, cherry")
    }

    @Test("Converts empty array to empty string")
    func fromEmptyArray() {
        #expect(String.convertToString([] as [Any]) == "")
    }

    @Test("Returns nil for an unrecognized type")
    func fromUnknownType() {
        struct UnknownType {}
        #expect(String.convertToString(UnknownType()) == nil)
    }
}

// MARK: - Dictionary.first(upTo:)

@Suite("Dictionary.first(upTo:)")
struct DictionaryFirstUpToTests {

    @Test("Leaves dictionary unchanged when count is below limit")
    func belowLimit() {
        var dict: [String: Int] = ["a": 1, "b": 2]
        dict.first(upTo: 5)
        #expect(dict.count == 2)
    }

    @Test("Reduces dictionary to maxItems when count exceeds limit")
    func aboveLimit() {
        var dict: [String: Int] = ["a": 1, "b": 2, "c": 3, "d": 4, "e": 5]
        dict.first(upTo: 3)
        #expect(dict.count == 3)
    }

    @Test("Leaves dictionary unchanged when count equals limit")
    func atLimit() {
        var dict: [String: Int] = ["a": 1, "b": 2, "c": 3]
        dict.first(upTo: 3)
        #expect(dict.count == 3)
    }

    @Test("Empty dictionary stays empty")
    func emptyDict() {
        var dict: [String: Int] = [:]
        dict.first(upTo: 5)
        #expect(dict.isEmpty)
    }

    @Test("Removes all entries when limit is zero")
    func zeroLimit() {
        var dict: [String: Int] = ["a": 1, "b": 2]
        dict.first(upTo: 0)
        #expect(dict.isEmpty)
    }
}

// MARK: - FirebaseAnalyticsService

@Suite("FirebaseAnalyticsService")
struct FirebaseAnalyticsServiceTests {

    @Test("Can be initialized without crashing")
    func initialization() {
        _ = FirebaseAnalyticsService()
    }
}
