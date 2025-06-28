//
//  PushManagerProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.06.2025.
//

import Foundation

protocol PushManagerProtocol: Sendable {
    func reuestAuthorization() async throws -> Bool
    func canRequestAuthorization() async -> Bool
    func schedulePushNotificationForTheNextWeek()
}
