//
//  FirebaseCrashlyticsService.swift
//  LoggingService
//

import Foundation
import FirebaseCrashlytics
import LoggingService

public struct FirebaseCrashlyticsService {}

extension FirebaseCrashlyticsService: LogServiceProtocol {

    public func identify(userId: String, name: String?, email: String?) {
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

    public func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        guard isHighPriority else { return }
        for (key, value) in dict {
            Crashlytics
                .crashlytics()
                .setCustomValue(value, forKey: key)
        }
    }

    public func deleteUserProfile() {
        Crashlytics.crashlytics().setUserID("new")
    }

    public func trackEvent(event: any LoggableEvent) {
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

    public func trackScreen(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
