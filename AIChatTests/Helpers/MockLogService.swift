//
//  MockLogService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 19.07.2025.
//

import Foundation
@testable import AIChat

final class MockLogService: @unchecked Sendable {
    
    var identifiedUsers: [(userId: String, name: String?, email: String?)] = []
    var trackedEvents: [AnyLoggableEvent] = []
    var addedUserProperties: [[String : Any]] = []
}

extension MockLogService: LogServiceProtocol {
    func identify(userId: String, name: String?, email: String?) {
        identifiedUsers.append((userId, name, email))
    }

    func addUserProperties(dict: [String : Any], isHighPriority: Bool) {
        addedUserProperties.append(dict)
    }

    func deleteUserProfile() {}

    func trackEvent(event: any AIChat.LoggableEvent) {
        let anyEvent = AnyLoggableEvent(
            eventName: event.eventName,
            parameters: event.parameters,
            type: event.type
        )
        
        trackedEvents.append(anyEvent)
    }

    func trackScreen(event: any AIChat.LoggableEvent) {
        let anyEvent = AnyLoggableEvent(
            eventName: event.eventName,
            parameters: event.parameters,
            type: event.type
        )
        
        trackedEvents.append(anyEvent)
    }
}
