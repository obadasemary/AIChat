//
//  LoggableEvent.swift
//  SamuraiLogging
//
//  Created by Abdelrahman Mohamed on 24.06.2025.
//

import Foundation

public protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: LogType { get }
}
