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
    func sameStringProducesSameHash() {
        let string = "test_event"
        #expect(string.stableHashValue == string.stableHashValue)
    }

    @Test("Different strings produce different hashes")
    func differentStringsProduceDifferentHashes() {
        #expect("event_a".stableHashValue != "event_b".stableHashValue)
    }

    @Test("Empty string produces a hash without crashing")
    func emptyStringProducesHash() {
        let hash = "".stableHashValue
        #expect(hash == 5381)
    }

    @Test("Hash is deterministic across calls")
    func hashIsDeterministic() {
        let value = "deterministic_test"
        #expect(value.stableHashValue == value.stableHashValue)
    }
}

// MARK: - FirebaseCrashlyticsService

@Suite("FirebaseCrashlyticsService")
struct FirebaseCrashlyticsServiceTests {

    @Test("Can be initialized without crashing")
    func initialization() {
        _ = FirebaseCrashlyticsService()
    }

    // trackEvent: .info and .analytic are no-ops — Firebase is never called
    @Test("trackEvent does not crash for .info events")
    func trackEvent_info_isNoOp() {
        let service = FirebaseCrashlyticsService()
        let event = AnyLoggableEvent(eventName: "info_event", type: .info)
        service.trackEvent(event: event)
    }

    @Test("trackEvent does not crash for .analytic events")
    func trackEvent_analytic_isNoOp() {
        let service = FirebaseCrashlyticsService()
        let event = AnyLoggableEvent(eventName: "analytic_event", type: .analytic)
        service.trackEvent(event: event)
    }

    @Test("trackScreen delegates to trackEvent without crashing for .info events")
    func trackScreen_info_isNoOp() {
        let service = FirebaseCrashlyticsService()
        let event = AnyLoggableEvent(eventName: "screen_view", type: .info)
        service.trackScreen(event: event)
    }

    // addUserProperties: low-priority calls are silently dropped
    @Test("addUserProperties does not crash when isHighPriority is false")
    func addUserProperties_lowPriority_isNoOp() {
        let service = FirebaseCrashlyticsService()
        service.addUserProperties(dict: ["key": "value"], isHighPriority: false)
    }
}
