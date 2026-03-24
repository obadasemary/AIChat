//
//  SamuraiLoggingFirebaseCrashlyticsTests.swift
//  SamuraiLoggingFirebaseCrashlytics
//
//  Created by Abdelrahman Mohamed on 18.03.2026.
//

import Testing
@testable import SamuraiLoggingFirebaseCrashlytics

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
}

// MARK: - FirebaseCrashlyticsService

@Suite("FirebaseCrashlyticsService")
struct FirebaseCrashlyticsServiceTests {

    @Test("Can be initialized without crashing")
    func initialization() {
        _ = FirebaseCrashlyticsService()
    }
}
