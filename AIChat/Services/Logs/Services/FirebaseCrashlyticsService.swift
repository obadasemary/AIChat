//
//  FirebaseCrashlyticsService.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 25.06.2025.
//

import Foundation
import FirebaseCrashlytics

struct FirebaseCrashlyticsService {
    
    init() {}
}

extension FirebaseCrashlyticsService: LogServiceProtocol {
    
    func identify(userId: String, name: String?, email: String?) {
        Crashlytics.crashlytics().setUserID(userId)
        
        if let name {
            Crashlytics
                .crashlytics()
                .setCustomValue(name, forKey: "account_name")
        }
        
        if let email {
            Crashlytics
                .crashlytics()
                .setCustomValue(email, forKey: "account_email")
        }
    }

    func addUserProperties(dict: [String : Any], isHighPriority: Bool) {
        guard isHighPriority else { return }
        for (key, value) in dict {
            Crashlytics
                .crashlytics()
                .setCustomValue(value, forKey: key)
        }
    }

    func deleteUserProfile() {
        Crashlytics.crashlytics().setUserID("new")
    }

    func trackEvent(event: any LoggableEvent) {
        switch event.type {
        case .info, .analytic:
            break
        case .severe, .warning:
            let error = NSError(
                domain: event.eventName,
                code: event.eventName.stableHashValue,
                userInfo: event.parameters
            )
            Crashlytics
                .crashlytics()
                .record(error: error, userInfo: event.parameters)
        }
    }

    func trackScreen(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
