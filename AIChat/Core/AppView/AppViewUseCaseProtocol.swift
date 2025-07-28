//
//  AppViewUseCaseProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol AppViewUseCaseProtocol {
    var auth: UserAuthInfo? { get }
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func trackEvent(event: any LoggableEvent)
}
