//
//  SamuraiLoggingTests.swift
//  SamuraiLogging
//
//  Created by Abdelrahman Mohamed on 24.06.2025.
//

import Testing
@testable import SamuraiLogging

@Suite("SamuraiLogging Tests")
struct SamuraiLoggingTests {

    @Test("LogType emoji returns correct value")
    func test_logTypeEmoji_returnsCorrectValue() {
        #expect(LogType.info.emoji == "🚀🚀🚀")
        #expect(LogType.analytic.emoji == "📊📊📊")
        #expect(LogType.warning.emoji == "⚠️⚠️⚠️")
        #expect(LogType.severe.emoji == "🚨🚨🚨")
    }

    @Test("AnyLoggableEvent stores values correctly")
    func test_anyLoggableEvent_storesValuesCorrectly() {
        let event = AnyLoggableEvent(
            eventName: "test_event",
            parameters: ["key": "value"],
            type: .analytic
        )
        #expect(event.eventName == "test_event")
        #expect(event.type == .analytic)
        #expect(event.parameters?["key"] as? String == "value")
    }

    @Test("AnyLoggableEvent defaults to analytic type")
    func test_anyLoggableEvent_defaultsToAnalyticType() {
        let event = AnyLoggableEvent(eventName: "test_event")
        #expect(event.type == .analytic)
        #expect(event.parameters == nil)
    }
}
