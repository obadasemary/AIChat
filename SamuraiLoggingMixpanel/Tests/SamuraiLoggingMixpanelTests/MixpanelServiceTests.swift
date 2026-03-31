//
//  MixpanelServiceTests.swift
//  SamuraiLoggingMixpanel
//
//  Created by Abdelrahman Mohamed on 31.03.2026.
//

import Testing
@testable import SamuraiLoggingMixpanel
import SamuraiLogging

// MARK: - MixpanelService

@Suite("MixpanelService")
struct MixpanelServiceTests {

    @Test("Can be initialized with a token without crashing")
    func test_whenInitializedWithToken_thenDoesNotCrash() {
        _ = MixpanelService(token: "test_token")
    }

    @Test("Can be initialized with logging enabled without crashing")
    func test_whenInitializedWithLoggingEnabled_thenDoesNotCrash() {
        _ = MixpanelService(token: "test_token", loggingEnabled: true)
    }

    // trackEvent: .info events are explicitly dropped before touching Mixpanel
    @Test("trackEvent does not crash for .info events")
    func test_whenTrackingInfoEvent_thenDoesNotCrash() {
        let service = MixpanelService(token: "test_token")
        let event = AnyLoggableEvent(eventName: "info_event", type: .info)
        service.trackEvent(event: event)
    }

    @Test("trackScreen does not crash for .info events")
    func test_whenTrackingInfoScreen_thenDoesNotCrash() {
        let service = MixpanelService(token: "test_token")
        let event = AnyLoggableEvent(eventName: "screen_view", type: .info)
        service.trackScreen(event: event)
    }

    @Test("trackEvent does not crash for analytic events with no parameters")
    func test_whenTrackingAnalyticEventWithNoParameters_thenDoesNotCrash() {
        let service = MixpanelService(token: "test_token")
        let event = AnyLoggableEvent(eventName: "purchase_completed", type: .analytic)
        service.trackEvent(event: event)
    }

    @Test("trackEvent does not crash for analytic events with parameters")
    func test_whenTrackingAnalyticEventWithParameters_thenDoesNotCrash() {
        let service = MixpanelService(token: "test_token")
        let event = AnyLoggableEvent(
            eventName: "purchase_completed",
            parameters: ["amount": 9.99, "currency": "USD"],
            type: .analytic
        )
        service.trackEvent(event: event)
    }

    @Test("addUserProperties does not crash with valid properties")
    func test_whenAddingUserProperties_thenDoesNotCrash() {
        let service = MixpanelService(token: "test_token")
        service.addUserProperties(dict: ["plan": "pro", "age": 30], isHighPriority: false)
    }

    @Test("deleteUserProfile does not crash")
    func test_whenDeletingUserProfile_thenDoesNotCrash() {
        let service = MixpanelService(token: "test_token")
        service.deleteUserProfile()
    }
}
