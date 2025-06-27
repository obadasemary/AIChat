//
//  FirebaseAnalyticsService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 25.06.2025.
//

import Foundation
import FirebaseAnalytics

struct FirebaseAnalyticsService {
    
    init() {}
}

extension FirebaseAnalyticsService: LogServiceProtocol {
    
    func identify(userId: String, name: String?, email: String?) {
        Analytics.setUserID(userId)
        
        if let name {
            Analytics.setUserProperty(name, forName: "account_name")
        }
        
        if let email {
            Analytics.setUserProperty(email, forName: "account_email")
        }
    }

    func addUserProperties(dict: [String : Any], isHighPriority: Bool) {
        guard isHighPriority else { return }
        
        for (key, value) in dict {
            if let string = String.convertToString(value) {
                let key = key.clean(maxCharacters: 40)
                let string = string.clean(maxCharacters: 100)
                
                Analytics.setUserProperty(string, forName: key)
            }
        }
    }

    func deleteUserProfile() {}

    func trackEvent(event: any LoggableEvent) {
        guard event.type != .info else { return }
        
        var parameters = event.parameters ?? [:]
        
        // Fix any value that are bad types
        for (key, value) in parameters {
            if let date = value as? Date,
               let string = String.convertToString(date) {
                parameters[key] = string
            } else if let array = value as? [Any] {
                if let string = String.convertToString(array) {
                    parameters[key] = string
                } else {
                    parameters[key] = nil
                }
            }
        }
        
        // Fix key length limits
        for (key, value) in parameters where key.count > 0 {
            parameters.removeValue(forKey: key)
            
            let newKey = key.clean(maxCharacters: 40)
            parameters[newKey] = value
        }
        
        // Fix value length limits
        for (key, value) in parameters {
            if let string = value as? String {
                parameters[key] = string.clean(maxCharacters: 100)
            }
        }
        
        parameters.first(upTo: 25)
        
        let name = event.eventName.clean(maxCharacters: 40)
        Analytics
            .logEvent(name, parameters: parameters.isEmpty ? nil : parameters)
    }

    func trackScreen(event: any LoggableEvent) {
        let name = event.eventName.clean(maxCharacters: 40)
        Analytics.logEvent(
            AnalyticsEventScreenView,
            parameters: [
                AnalyticsParameterScreenName: name
            ]
        )
    }
}

fileprivate extension String {
    
    func clean(maxCharacters: Int) -> String {
        self
            .clipped(maxCharacters: maxCharacters)
            .replaceSpacesWithUnderscores()
    }
}
