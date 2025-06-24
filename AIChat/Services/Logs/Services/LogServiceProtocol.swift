//
//  LogServiceProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 24.06.2025.
//

import Foundation

protocol LogServiceProtocol: Sendable {
    func identify(userId: String, name: String?, email: String?)
    func addUserProperty(dict: [String: Any], isHighPriority: Bool)
    func deleteUserProfile()
    func trackEvent(event: LoggableEvent)
    func trackScreen(event: LoggableEvent)
}
