//
//  LoggableEvent.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 24.06.2025.
//

import Foundation

protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: LogType { get }
}

struct AnyLoggableEvent: LoggableEvent {
    
    let eventName: String
    let parameters: [String : Any]?
    let type: LogType
    
    init(
        eventName: String,
        parameters: [String : Any]? = nil,
        type: LogType = .analytic
    ) {
        self.eventName = eventName
        self.parameters = parameters
        self.type = type
    }
}
