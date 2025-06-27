//
//  LogManagerProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 24.06.2025.
//

protocol LogManagerProtocol: Sendable {
    func identify(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any], isHighPriority: Bool)
    func deleteUserProfile()
    func trackEvent(event: LoggableEvent)
    func trackScreen(event: LoggableEvent)
}
