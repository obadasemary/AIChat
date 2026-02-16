//
//  ConsoleService.swift
//  LoggingService
//

import Foundation

public struct ConsoleService {

    private let logger: LogSystem
    private let printParameters: Bool

    public init(
        logger: LogSystem = LogSystem(),
        printParameters: Bool = true
    ) {
        self.logger = logger
        self.printParameters = printParameters
    }
}

extension ConsoleService: LogServiceProtocol {
    public func identify(userId: String, name: String?, email: String?) {
        let message = """
📊 Identify User
    userId: \(userId)
    name: \(name ?? "unknown")
    email: \(email ?? "unknown")
"""

        logger.log(level: LogType.info, message: message)
    }

    public func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        var message = """
📊 Log User Properties (isHighPriority: \(isHighPriority.description))
"""
        if printParameters {
            let sortedKeys = dict.keys.sorted()
            for key in sortedKeys {
                if let value = dict[key] {
                    message += "\n (key: \(key), value: \(value))"
                }
            }
        }

        logger.log(level: LogType.info, message: message)
    }

    public func deleteUserProfile() {
        let message = """
📊 Delete User Profile
"""

        logger.log(level: LogType.info, message: message)
    }

    public func trackEvent(event: any LoggableEvent) {
        var message = "\(event.type.emoji) \(event.eventName)"

        if printParameters, let parameters = event.parameters, !parameters.isEmpty {

            let sortedKeys = parameters.keys.sorted()
            for key in sortedKeys {
                if let value = parameters[key] {
                    message += "\n (key: \(key), value: \(value))"
                }
            }
        }

        logger.log(level: event.type, message: message)
    }

    public func trackScreen(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
