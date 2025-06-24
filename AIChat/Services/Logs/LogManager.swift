//
//  LogManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 23.06.2025.
//

import Foundation

@MainActor
@Observable
final class LogManager {
    
    private let services: [LogServiceProtocol]
    
    init(services: [LogServiceProtocol] = []) {
        self.services = services
    }
}

extension LogManager: LogManagerProtocol {
    
    nonisolated func identify(userId: String, name: String?, email: String?) {
        for service in self.services {
            service.identify(userId: userId, name: name, email: email)
        }
    }

    nonisolated func addUserProperty(dict: [String : Any]) {
        for service in self.services {
            service.addUserProperty(dict: dict)
        }
    }

    nonisolated func deleteUserProfile() {
        for service in self.services {
            service.deleteUserProfile()
        }
    }

    nonisolated func trackEvent(event: any LoggableEvent) {
        for service in self.services {
            service.trackEvent(event: event)
        }
    }

    nonisolated func trackScreen(event: any LoggableEvent) {
        for service in self.services {
            service.trackScreen(event: event)
        }
    }
}

private extension LogManager {
    
}
