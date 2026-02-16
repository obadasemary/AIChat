//
//  LoggableEvent.swift
//  LoggingService
//

import Foundation

public protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: LogType { get }
}

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
