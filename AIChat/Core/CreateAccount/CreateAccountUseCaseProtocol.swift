//
//  CreateAccountUseCaseProtocol.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol CreateAccountUseCaseProtocol {
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signInWithGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
    func trackEvent(event: any LoggableEvent)
}
