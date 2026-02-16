//
//  LogManagerTests.swift
//  LoggingService
//

import Testing
@testable import LoggingService

@MainActor
@Suite
struct LogManagerTests {

    @Test
    func test_init_withNoServices_doesNotCrash() {
        let manager = LogManager(services: [])
        manager.trackEvent(eventName: "test_event")
    }
}
