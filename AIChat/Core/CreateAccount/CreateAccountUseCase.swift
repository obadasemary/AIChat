//
//  CreateAccountUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
final class CreateAccountUseCase {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
}

extension CreateAccountUseCase: CreateAccountUseCaseProtocol {
    
    func signInWithApple() async throws -> (
        user: UserAuthInfo,
        isNewUser: Bool
    ) {
        try await authManager.signInWithApple()
    }

    func signInWithGoogle() async throws -> (
        user: UserAuthInfo,
        isNewUser: Bool
    ) {
        try await authManager.signInWithGoogle()
    }

    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.logIn(auth: auth, isNewUser: isNewUser)
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
