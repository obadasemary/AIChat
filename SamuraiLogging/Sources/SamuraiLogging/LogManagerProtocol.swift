//
//  LogManagerProtocol.swift
//  SamuraiLogging
//
//  Created by Abdelrahman Mohamed on 18.03.2026.
//

import Foundation

public protocol LogManagerProtocol: Sendable {
    func identify(userId: String, name: String?, email: String?)
    func addUserProperties(dict: [String: Any], isHighPriority: Bool)
    func deleteUserProfile()
    
    func trackEvent(event: LoggableEvent)
    func trackScreen(event: LoggableEvent)
}
