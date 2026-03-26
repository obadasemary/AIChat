//
//  SamuraiLoggingFirebaseCrashlyticsTests.swift
//  SamuraiLoggingFirebaseCrashlytics
//
//  Created by Abdelrahman Mohamed on 18.03.2026.
//

import Testing
@testable import SamuraiLoggingFirebaseCrashlytics
import SamuraiLogging

// MARK: - String.stableHashValue

@Suite("String.stableHashValue")
struct StringStableHashValueTests {

    @Test("Same string produces the same hash")
    func test_whenSameString_thenSameHash() {
        let string = "test_event"
        #expect(string.stableHashValue == string.stableHashValue)
    }

    @Test("Different strings produce different hashes")
    func test_whenDifferentStrings_thenDifferentHashes() {
        #expect("event_a".stableHashValue != "event_b".stableHashValue)
    }

    @Test("Empty string produces a hash without crashing")
    func test_whenEmptyString_thenProducesHash() {
        let hash = "".stableHashValue
        #expect(hash == 5381)
    }

    @Test("Hash is deterministic across calls")
    func test_whenCalledMultipleTimes_thenHashIsDeterministic() {
        let value = "deterministic_test"
        #expect(value.stableHashValue == value.stableHashValue)
    }
}

// MARK: - FirebaseCrashlyticsService

@Suite("FirebaseCrashlyticsService")
struct FirebaseCrashlyticsServiceTests {

    @Test("Can be initialized without crashing")
    func test_whenInitialized_thenDoesNotCrash() {
        _ = FirebaseCrashlyticsService()
    }

    // trackEvent: .info and .analytic are no-ops — Firebase is never called
    @Test("trackEvent does not crash for .info events")
    func test_whenTrackingInfoEvent_thenDoesNotCrash() {
        let service = FirebaseCrashlyticsService()
        let event = AnyLoggableEvent(eventName: "info_event", type: .info)
        service.trackEvent(event: event)
    }

    @Test("trackEvent does not crash for .analytic events")
    func test_whenTrackingAnalyticEvent_thenDoesNotCrash() {
        let service = FirebaseCrashlyticsService()
        let event = AnyLoggableEvent(eventName: "analytic_event", type: .analytic)
        service.trackEvent(event: event)
    }

    @Test("trackScreen delegates to trackEvent without crashing for .info events")
    func test_whenTrackingInfoScreen_thenDoesNotCrash() {
        let service = FirebaseCrashlyticsService()
        let event = AnyLoggableEvent(eventName: "screen_view", type: .info)
        service.trackScreen(event: event)
    }

    // addUserProperties: low-priority calls are silently dropped
    @Test("addUserProperties does not crash when isHighPriority is false")
    func test_whenAddingLowPriorityUserProperties_thenDoesNotCrash() {
        let service = FirebaseCrashlyticsService()
        service.addUserProperties(dict: ["key": "value"], isHighPriority: false)
    }
}
