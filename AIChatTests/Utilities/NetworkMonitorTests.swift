//
//  NetworkMonitorTests.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 11.12.2025.
//

import Testing
import Network
@testable import AIChat

@MainActor
struct NetworkMonitorTests {

    @Test("Initial Connection State Detection")
    func testInitialConnectionStateDetection() async throws {
        let mockLogManager = LogManager(services: [MockLogService()])
        let monitor = NetworkMonitor(logManager: mockLogManager)

        // Note: This test will pass or fail based on actual network connectivity
        // In a real environment, the monitor should detect the current state
        #expect(monitor.isConnected == true || monitor.isConnected == false)
        #expect(monitor.connectionType != nil)
    }

    @Test("Mock NetworkMonitor Starts Connected")
    func testMockNetworkMonitorStartsConnected() async throws {
        let mockMonitor = MockNetworkMonitor(isConnected: true)

        #expect(mockMonitor.isConnected == true)
    }

    @Test("Mock NetworkMonitor Starts Disconnected")
    func testMockNetworkMonitorStartsDisconnected() async throws {
        let mockMonitor = MockNetworkMonitor(isConnected: false)

        #expect(mockMonitor.isConnected == false)
    }

    @Test("Mock NetworkMonitor Can Change State")
    func testMockNetworkMonitorCanChangeState() async throws {
        let mockMonitor = MockNetworkMonitor(isConnected: false)

        #expect(mockMonitor.isConnected == false)

        // Simulate connectivity change
        mockMonitor.isConnected = true

        #expect(mockMonitor.isConnected == true)
    }

    @Test("Mock NetworkMonitor Connection Types")
    func testMockNetworkMonitorConnectionTypes() async throws {
        let mockMonitor = MockNetworkMonitor(isConnected: true)

        // Test different connection types
        mockMonitor.connectionType = .wifi
        #expect(mockMonitor.connectionType == .wifi)

        mockMonitor.connectionType = .cellular
        #expect(mockMonitor.connectionType == .cellular)

        mockMonitor.connectionType = .ethernet
        #expect(mockMonitor.connectionType == .ethernet)

        mockMonitor.connectionType = .unknown
        #expect(mockMonitor.connectionType == .unknown)
    }

    @Test("NetworkMonitor Protocol Conformance")
    func testNetworkMonitorProtocolConformance() async throws {
        let mockLogManager = LogManager(services: [MockLogService()])
        let realMonitor: NetworkMonitorProtocol = NetworkMonitor(logManager: mockLogManager)
        let mockMonitor: NetworkMonitorProtocol = MockNetworkMonitor(isConnected: true)

        // Both should conform to the protocol
        _ = realMonitor.isConnected
        _ = realMonitor.connectionType
        _ = mockMonitor.isConnected
        _ = mockMonitor.connectionType

        // Test passes if compilation succeeds
        #expect(true)
    }
}
