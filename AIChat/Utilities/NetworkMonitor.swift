//
//  NetworkMonitor.swift
//  AIChat
//
//  Created by Claude on 10.12.2025.
//

import Foundation
import Network

@MainActor
@Observable
final class NetworkMonitor {

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private(set) var isConnected: Bool = false
    private(set) var connectionType: ConnectionType = .unknown

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    init() {
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
                print("🌐 NetworkMonitor: Connection changed - \(path.status == .satisfied ? "Connected" : "Disconnected")")
                self.isConnected = path.status == .satisfied
                self.updateConnectionType(from: path)
            }
        }
        monitor.start(queue: queue)
    }

    private func updateConnectionType(from path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
            print("🌐 NetworkMonitor: Connection type - WiFi")
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
            print("🌐 NetworkMonitor: Connection type - Cellular")
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
            print("🌐 NetworkMonitor: Connection type - Ethernet")
        } else {
            connectionType = .unknown
            print("🌐 NetworkMonitor: Connection type - Unknown")
        }
    }

    deinit {
        monitor.cancel()
    }
}
