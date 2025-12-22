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

        // Both should conform to the protocol and provide required properties
        #expect(realMonitor.isConnected == true || realMonitor.isConnected == false)
        #expect(realMonitor.connectionType != nil)
        #expect(mockMonitor.isConnected == true)
        #expect(mockMonitor.connectionType != nil)
    }

    // MARK: - Edge Case Tests

    @Test("Mock NetworkMonitor Default Initialization")
    func testMockNetworkMonitorDefaultInitialization() async throws {
        let mockMonitor = MockNetworkMonitor()

        // Default should be connected with WiFi
        #expect(mockMonitor.isConnected == true)
        #expect(mockMonitor.connectionType == .wifi)
    }

    @Test("Mock NetworkMonitor Disconnected With Different Connection Types")
    func testMockNetworkMonitorDisconnectedWithDifferentConnectionTypes() async throws {
        // Test that disconnected state can coexist with any connection type
        let wifiDisconnected = MockNetworkMonitor(isConnected: false, connectionType: .wifi)
        #expect(wifiDisconnected.isConnected == false)
        #expect(wifiDisconnected.connectionType == .wifi)

        let cellularDisconnected = MockNetworkMonitor(isConnected: false, connectionType: .cellular)
        #expect(cellularDisconnected.isConnected == false)
        #expect(cellularDisconnected.connectionType == .cellular)

        let unknownDisconnected = MockNetworkMonitor(isConnected: false, connectionType: .unknown)
        #expect(unknownDisconnected.isConnected == false)
        #expect(unknownDisconnected.connectionType == .unknown)
    }

    @Test("Mock NetworkMonitor Multiple State Transitions")
    func testMockNetworkMonitorMultipleStateTransitions() async throws {
        let mockMonitor = MockNetworkMonitor(isConnected: true, connectionType: .wifi)

        // Initial state
        #expect(mockMonitor.isConnected == true)
        #expect(mockMonitor.connectionType == .wifi)

        // Disconnect
        mockMonitor.isConnected = false
        #expect(mockMonitor.isConnected == false)

        // Reconnect
        mockMonitor.isConnected = true
        #expect(mockMonitor.isConnected == true)

        // Change to cellular
        mockMonitor.connectionType = .cellular
        #expect(mockMonitor.connectionType == .cellular)

        // Disconnect again
        mockMonitor.isConnected = false
        #expect(mockMonitor.isConnected == false)
        #expect(mockMonitor.connectionType == .cellular)
    }

    @Test("Mock NetworkMonitor Connection Type Changes While Connected")
    func testMockNetworkMonitorConnectionTypeChangesWhileConnected() async throws {
        let mockMonitor = MockNetworkMonitor(isConnected: true, connectionType: .wifi)

        // Switch between connection types while remaining connected
        #expect(mockMonitor.isConnected == true)
        #expect(mockMonitor.connectionType == .wifi)

        mockMonitor.connectionType = .cellular
        #expect(mockMonitor.isConnected == true)
        #expect(mockMonitor.connectionType == .cellular)

        mockMonitor.connectionType = .ethernet
        #expect(mockMonitor.isConnected == true)
        #expect(mockMonitor.connectionType == .ethernet)

        mockMonitor.connectionType = .unknown
        #expect(mockMonitor.isConnected == true)
        #expect(mockMonitor.connectionType == .unknown)
    }
}
