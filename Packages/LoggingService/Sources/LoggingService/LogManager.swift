//
//  LogManager.swift
//  LoggingService
//

import Foundation
import Observation

@MainActor
@Observable
public final class LogManager {

    private let services: [LogServiceProtocol]

    public init(services: [LogServiceProtocol] = []) {
        self.services = services
    }
}

extension LogManager: LogManagerProtocol {

    nonisolated public func identify(userId: String, name: String?, email: String?) {
        for service in self.services {
            service.identify(userId: userId, name: name, email: email)
        }
    }

    nonisolated public func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        for service in self.services {
            service.addUserProperties(dict: dict, isHighPriority: isHighPriority)
        }
    }

    nonisolated public func deleteUserProfile() {
        for service in self.services {
            service.deleteUserProfile()
        }
    }

    nonisolated public func trackEvent(
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

    nonisolated public func trackEvent(event: AnyLoggableEvent) {
        for service in self.services {
            service.trackEvent(event: event)
        }
    }

    nonisolated public func trackEvent(event: any LoggableEvent) {
        for service in self.services {
            service.trackEvent(event: event)
        }
    }

    nonisolated public func trackScreen(event: any LoggableEvent) {
        for service in self.services {
            service.trackScreen(event: event)
        }
    }
}
