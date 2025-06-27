//
//  ConsoleService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 24.06.2025.
//

import Foundation

struct ConsoleService {
    
    private let logger: LogSystem
    private let printParameters: Bool
    
    init(
        logger: LogSystem = LogSystem(),
        printParameters: Bool = true
    ) {
        self.logger = logger
        self.printParameters = printParameters
    }
}

extension ConsoleService: LogServiceProtocol {
    func identify(userId: String, name: String?, email: String?) {
        let message = """
📊 Identify User
    userId: \(userId)
    name: \(name ?? "unknown")
    email: \(email ?? "unknown")
"""
        
        logger.log(level: LogType.info, message: message)
    }

    func addUserProperties(dict: [String : Any], isHighPriority: Bool) {
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

    func deleteUserProfile() {
        let message = """
📊 Delete User Profile                
"""
        
        logger.log(level: LogType.info, message: message)
    }

    func trackEvent(event: any LoggableEvent) {
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

    func trackScreen(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
