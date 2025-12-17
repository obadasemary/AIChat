//
//  CreateAccountUseCase.swift
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

@MainActor
final class CreateAccountUseCase {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        guard let authManager = container.resolve(AuthManager.self) else {
            fatalError("Failed to resolve AuthManager for CreateAccountUseCase")
        }
        guard let userManager = container.resolve(UserManager.self) else {
            fatalError("Failed to resolve UserManager for CreateAccountUseCase")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            fatalError("Failed to resolve LogManager for CreateAccountUseCase")
        }
        
        self.authManager = authManager
        self.userManager = userManager
        self.logManager = logManager
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
