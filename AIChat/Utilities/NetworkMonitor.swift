//
//  NetworkMonitor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 10.12.2025.
//

import Foundation
import Network

enum NetworkConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
}

@MainActor
protocol NetworkMonitorProtocol {
    var isConnected: Bool { get }
    var connectionType: NetworkConnectionType { get }
}

@MainActor
@Observable
final class NetworkMonitor: NetworkMonitorProtocol {

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let logManager: LogManagerProtocol

    private(set) var isConnected: Bool = false
    private(set) var connectionType: NetworkConnectionType = .unknown

    // Track previous state to avoid logging duplicate events
    private var previousIsConnected: Bool?
    private var previousConnectionType: NetworkConnectionType?

    init(logManager: LogManagerProtocol) {
        self.logManager = logManager

        // Get initial network state synchronously
        let currentPath = monitor.currentPath
        isConnected = currentPath.status == .satisfied
        connectionType = determineConnectionType(from: currentPath)

        // Set initial previous state to avoid logging on first update
        previousIsConnected = isConnected
        previousConnectionType = connectionType

        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self else { return }

                let newIsConnected = path.status == .satisfied
                let newConnectionType = self.determineConnectionType(from: path)

                // Only log if state actually changed
                self.logNetworkStateChangeIfNeeded(
                    newIsConnected: newIsConnected,
                    newConnectionType: newConnectionType
                )

                self.isConnected = newIsConnected
                self.connectionType = newConnectionType
                self.previousIsConnected = newIsConnected
                self.previousConnectionType = newConnectionType
            }
        }
        monitor.start(queue: queue)
    }

    private func determineConnectionType(from path: NWPath) -> NetworkConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .ethernet
        } else {
            return .unknown
        }
    }

    private func logNetworkStateChangeIfNeeded(
        newIsConnected: Bool,
        newConnectionType: NetworkConnectionType
    ) {
        // Only log if state actually changed (rate limiting)
        guard newIsConnected != previousIsConnected ||
              newConnectionType != previousConnectionType else {
            return
        }

        #if DEBUG
        // Combine both status and type into a single log entry
        let status = newIsConnected ? "Connected" : "Disconnected"
        let type = connectionTypeString(newConnectionType)

        let event = AnyLoggableEvent(
            eventName: "network_state_changed",
            parameters: [
                "status": status,
                "connection_type": type
            ],
            type: .info
        )
        logManager.trackEvent(event: event)
        #endif
    }

    private func connectionTypeString(_ type: NetworkConnectionType) -> String {
        switch type {
        case .wifi: return "wifi"
        case .cellular: return "cellular"
        case .ethernet: return "ethernet"
        case .unknown: return "unknown"
        }
    }

    deinit {
        monitor.cancel()
    }
}
