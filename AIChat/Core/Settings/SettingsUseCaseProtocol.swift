//
//  SettingsUseCaseProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol SettingsUseCaseProtocol {
    var auth: UserAuthInfo? { get }
    func signOut() throws
    func deleteAccount() async throws
    func trackEvent(event: any LoggableEvent)
}
