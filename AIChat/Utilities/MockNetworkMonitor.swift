//
//  MockNetworkMonitor.swift
//  AIChat
//
//  Created by Antigravity on 21.12.2025.
//

import Foundation

@MainActor
final class MockNetworkMonitor: NetworkMonitorProtocol {
    var isConnected: Bool
    var connectionType: NetworkConnectionType

    init(isConnected: Bool = true, connectionType: NetworkConnectionType = .wifi) {
        self.isConnected = isConnected
        self.connectionType = connectionType
    }
}
