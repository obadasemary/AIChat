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

    nonisolated func addUserProperty(dict: [String : Any], isHighPriority: Bool) {
        for service in self.services {
            service.addUserProperty(dict: dict, isHighPriority: isHighPriority)
        }
    }

    nonisolated func deleteUserProfile() {
        for service in self.services {
            service.deleteUserProfile()
        }
    }
    
    func trackEvent(
        eventName: String,
        parameters: [String : Any]? = nil,
        type: LogType = .analytic
    ) {
        let event = AnyLoggableEvent(
            eventName: eventName,
            parameters: parameters,
            type: type
        )
        for service in self.services {
            service.trackEvent(event: event)
        }
    }
    
    func trackEvent(event: AnyLoggableEvent) {
        for service in self.services {
            service.trackEvent(event: event)
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
