//
//  AnyLoggableEvent.swift
//  SamuraiLogging
//
//  Created by Abdelrahman Mohamed on 15.03.2026.
//

public struct AnyLoggableEvent: LoggableEvent {

    public let eventName: String
    public let parameters: [String: Any]?
    public let type: LogType

    public init(
        eventName: String,
        parameters: [String: Any]? = nil,
        type: LogType = .analytic
    ) {
        self.eventName = eventName
        self.parameters = parameters
        self.type = type
    }
}
