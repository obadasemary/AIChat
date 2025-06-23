//
//  LogManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 23.06.2025.
//

import Foundation

protocol LogServiceProtocol: Sendable {
    func identify(userId: String, name: String?, email: String?)
    func addUserProperty(dict: [String: Any])
    func deleteUserProfile()
    func trackEvent(event: LoggableEvent)
    func trackScreen(event: LoggableEvent)
}

struct ConsoleService {
    
}

extension ConsoleService: LogServiceProtocol {
    func identify(userId: String, name: String?, email: String?) {
        let string = """
Identify User
    userId: \(userId)
    name: \(name ?? "unknown")
    email: \(email ?? "unknown")
"""
        
        print(string)
    }

    func addUserProperty(dict: [String : Any]) {
        var string = """
Log User Properties                
"""
        
        let sortedKeys = dict.keys.sorted()
        for key in sortedKeys {
            if let value = dict[key] {
                string += "\n (key: \(key), value: \(value))"
            }
        }
        
        print(string)
    }

    func deleteUserProfile() {
        var string = """
Delete User Profile                
"""
        
        print(string)
    }

    func trackEvent(event: any LoggableEvent) {
        var string = "\(event.eventName)"
        
        if let parameters = event.parameters, !parameters.isEmpty {
            
            let sortedKeys = parameters.keys.sorted()
            for key in sortedKeys {
                if let value = parameters[key] {
                    string += "\n (key: \(key), value: \(value))"
                }
            }
        }
        
        print(string)
    }

    func trackScreen(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}

protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
}

protocol LogManagerProtocol: Sendable {
    func identify(userId: String, name: String?, email: String?)
    func addUserProperty(dict: [String: Any])
    func deleteUserProfile()
    func trackEvent(event: LoggableEvent)
    func trackScreen(event: LoggableEvent)
}

@MainActor
@Observable
final class LogManager {
    
    private let services: [LogServiceProtocol]
    
    init(services: [LogServiceProtocol] = []) {
        self.services = services
    }
}

extension LogManager: LogManagerProtocol {
    
    nonisolated func identify(userId: String, name: String?, email: String?) {
        for service in self.services {
            service.identify(userId: userId, name: name, email: email)
        }
    }

    nonisolated func addUserProperty(dict: [String : Any]) {
        for service in self.services {
            service.addUserProperty(dict: dict)
        }
    }

    nonisolated func deleteUserProfile() {
        for service in self.services {
            service.deleteUserProfile()
        }
    }

    nonisolated func trackEvent(event: any LoggableEvent) {
        for service in self.services {
            service.trackEvent(event: event)
        }
    }

    nonisolated func trackScreen(event: any LoggableEvent) {
        for service in self.services {
            service.trackScreen(event: event)
        }
    }
}

private extension LogManager {
    
}
