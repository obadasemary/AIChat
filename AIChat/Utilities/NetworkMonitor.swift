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

    init(logManager: LogManagerProtocol) {
        self.logManager = logManager

        // Get initial network state synchronously
        let currentPath = monitor.currentPath
        isConnected = currentPath.status == .satisfied
        updateConnectionType(from: currentPath)

        startMonitoring()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self else { return }
                let status = path.status == .satisfied ? "Connected" : "Disconnected"
                let event = AnyLoggableEvent(
                    eventName: "network_connection_changed",
                    parameters: ["status": status],
                    type: .info
                )
                self.logManager.trackEvent(event: event)
                self.isConnected = path.status == .satisfied
                self.updateConnectionType(from: path)
            }
        }
        monitor.start(queue: queue)
    }

    private func updateConnectionType(from path: NWPath) {
        let type: String
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
            type = "wifi"
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
            type = "cellular"
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
            type = "ethernet"
        } else {
            connectionType = .unknown
            type = "unknown"
        }

        let event = AnyLoggableEvent(
            eventName: "network_connection_type_updated",
            parameters: ["type": type],
            type: .info
        )
        logManager.trackEvent(event: event)
    }

    deinit {
        monitor.cancel()
    }
}
