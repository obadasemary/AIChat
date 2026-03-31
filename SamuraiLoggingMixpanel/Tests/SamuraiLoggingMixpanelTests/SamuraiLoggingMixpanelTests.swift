import Testing
@testable import SamuraiLoggingMixpanel
import SamuraiLogging

// MARK: - String.clipped(maxCharacters:)

@Suite("String.clipped(maxCharacters:)")
struct StringClippedTests {

    @Test("Returns string unchanged when shorter than limit", arguments: zip(
        ["hello", "", "hi"],
        [10, 5, 5]
    ))
    func test_whenInputShorterThanLimit_thenReturnsUnchanged(input: String, limit: Int) {
        #expect(input.clipped(maxCharacters: limit) == input)
    }

    @Test("Clips to exact character count")
    func test_whenClippingToExactCount_thenReturnsFirstNCharacters() {
        #expect("Hello, World!".clipped(maxCharacters: 5) == "Hello")
    }

    @Test("Returns empty string when limit is zero")
    func test_whenLimitIsZero_thenReturnsEmptyString() {
        #expect("hello".clipped(maxCharacters: 0) == "")
    }

    @Test("Clips a 255-char key to exactly 255 characters")
    func test_whenKeyExceeds255_thenClipsTo255() {
        let long = String(repeating: "a", count: 300)
        #expect(long.clipped(maxCharacters: 255).count == 255)
    }
}
