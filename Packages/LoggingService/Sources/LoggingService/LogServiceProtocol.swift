//
//  LogServiceProtocol.swift
//  LoggingService
//

import Foundation

public protocol LogServiceProtocol: Sendable {
    func identify(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any], isHighPriority: Bool)
    func deleteUserProfile()
    func trackEvent(event: any LoggableEvent)
    func trackScreen(event: any LoggableEvent)
}
