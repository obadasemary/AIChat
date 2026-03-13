//
//  LogManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 23.06.2025.
//

import Foundation

/// Central logging manager that fans events out to all registered log services.
///
/// Explicitly `Sendable`: `services` is an immutable `let` array of `Sendable`
/// values, so all methods are safe to call from any isolation context.
/// `@Observable` does not require `@MainActor`; removing it allows `LogManager`
/// to be safely captured in `@Sendable` closures without introducing data races.
@Observable
final class LogManager: @unchecked Sendable {

    private let services: [LogServiceProtocol]

    init(services: [LogServiceProtocol] = []) {
        self.services = services
    }
}

extension LogManager: LogManagerProtocol {

    func identify(userId: String, name: String?, email: String?) {
        for service in self.services {
            service.identify(userId: userId, name: name, email: email)
        }
    }

    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        for service in self.services {
            service.addUserProperties(dict: dict, isHighPriority: isHighPriority)
        }
    }

    func deleteUserProfile() {
        for service in self.services {
            service.deleteUserProfile()
        }
    }

    func trackEvent(
        eventName: String,
        parameters: [String: Any]? = nil,
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

    func trackEvent(event: any LoggableEvent) {
        for service in self.services {
            service.trackEvent(event: event)
        }
    }

    func trackScreen(event: any LoggableEvent) {
        for service in self.services {
            service.trackScreen(event: event)
        }
    }
}
