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

    @Test("Clips a 255-char key to exactly 255 characters")
    func clipsAtMixpanelKeyLimit() {
        let long = String(repeating: "a", count: 300)
        #expect(long.clipped(maxCharacters: 255).count == 255)
    }
}

// MARK: - MixpanelService

@Suite("MixpanelService")
struct MixpanelServiceTests {

    @Test("Can be initialized with a token without crashing")
    func initialization() {
        _ = MixpanelService(token: "test_token")
    }

    @Test("Can be initialized with logging enabled without crashing")
    func initializationWithLogging() {
        _ = MixpanelService(token: "test_token", loggingEnabled: true)
    }

    // trackEvent: .info events are explicitly dropped before touching Mixpanel
    @Test("trackEvent does not crash for .info events")
    func trackEvent_info_isNoOp() {
        let service = MixpanelService(token: "test_token")
        let event = AnyLoggableEvent(eventName: "info_event", type: .info)
        service.trackEvent(event: event)
    }

    @Test("trackScreen does not crash for .info events")
    func trackScreen_info_isNoOp() {
        let service = MixpanelService(token: "test_token")
        let event = AnyLoggableEvent(eventName: "screen_view", type: .info)
        service.trackScreen(event: event)
    }

    @Test("trackEvent does not crash for analytic events with no parameters")
    func trackEvent_analytic_noParameters() {
        let service = MixpanelService(token: "test_token")
        let event = AnyLoggableEvent(eventName: "purchase_completed", type: .analytic)
        service.trackEvent(event: event)
    }

    @Test("trackEvent does not crash for analytic events with parameters")
    func trackEvent_analytic_withParameters() {
        let service = MixpanelService(token: "test_token")
        let event = AnyLoggableEvent(
            eventName: "purchase_completed",
            parameters: ["amount": 9.99, "currency": "USD"],
            type: .analytic
        )
        service.trackEvent(event: event)
    }

    @Test("addUserProperties does not crash with valid properties")
    func addUserProperties() {
        let service = MixpanelService(token: "test_token")
        service.addUserProperties(dict: ["plan": "pro", "age": 30], isHighPriority: false)
    }

    @Test("deleteUserProfile does not crash")
    func deleteUserProfile() {
        let service = MixpanelService(token: "test_token")
        service.deleteUserProfile()
    }
}
