//
//  PushManager.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.06.2025.
//

import Foundation
import SwiftfulUtilities

@MainActor
@Observable
final class PushManager {
    
    private let logManager: LogManager?
    
    init(logManager: LogManager? = nil) {
        self.logManager = logManager
    }
}

extension PushManager: PushManagerProtocol {
    
    func reuestAuthorization() async throws -> Bool {
        let isAuthorized = try await LocalNotifications.requestAuthorization()
        logManager?.addUserProperties(
            dict: [
                "push_is_authorized": isAuthorized
            ],
            isHighPriority: true
        )
        return isAuthorized
    }
    
    func canRequestAuthorization() async -> Bool {
        await LocalNotifications.canRequestAuthorization()
    }
    
    nonisolated func schedulePushNotificationForTheNextWeek() {
        LocalNotifications.removeAllPendingNotifications()
        LocalNotifications.removeAllDeliveredNotifications()
        
        Task {
            do {
                // Tomorrow
                try await schedulePushNotification(
                    title: "Hey you! Ready to chat?",
                    subtitle: "Open AI Chat to begin!",
                    triggerDate: Date().addingTimeInterval(days: 1)
                )
                // In 3 days
                try await schedulePushNotification(
                    title: "Someone sent you a message!",
                    subtitle: "Open AI Chat to respond!",
                    triggerDate: Date().addingTimeInterval(days: 3)
                )
                
                // In 5 days
                try await schedulePushNotification(
                    title: "Hey stranger! we miss you",
                    subtitle: "Don't forget about us!",
                    triggerDate: Date().addingTimeInterval(days: 5)
                )
                
                logManager?
                    .trackEvent(
                        event: Event.weekScheduleSuccess
                    )
            } catch {
                logManager?
                    .trackEvent(
                        event: Event.weekScheduleFail(
                            error: error
                        )
                    )
            }
        }
    }
}

private extension PushManager {
    
    func schedulePushNotification(
        title: String,
        subtitle: String,
        triggerDate: Date
    ) async throws {
        let content = AnyNotificationContent(
            title: title,
            body: subtitle
        )
        let trigger = NotificationTriggerOption.date(
            date: triggerDate,
            repeats: false
        )
        try await LocalNotifications
            .scheduleNotification(
                content: content,
                trigger: trigger
            )
    }
}

// MARK: - Event
private extension PushManager {
    enum Event: LoggableEvent {
        case weekScheduleSuccess
        case weekScheduleFail(error: Error)
        
        var eventName: String {
            switch self {
            case .weekScheduleSuccess: "PushMan_WeekSchedule_Success"
            case .weekScheduleFail: "PushMan_WeekSchedule_Fail"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .weekScheduleFail(error: let error):
                error.eventParameters
            default:
                nil
            }
        }
        
        var type: LogType {
            switch self {
            case .weekScheduleFail:
                    .severe
            default:
                    .analytic
            }
        }
    }
}
