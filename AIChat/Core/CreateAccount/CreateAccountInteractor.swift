//
//  CreateAccountInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol CreateAccountInteractorProtocol {
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signInWithGoogle() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class CreateAccountInteractor {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        guard let authManager = container.resolve(AuthManager.self) else {
            preconditionFailure("Failed to resolve AuthManager for CreateAccountInteractor")
        }
        guard let userManager = container.resolve(UserManager.self) else {
            preconditionFailure("Failed to resolve UserManager for CreateAccountInteractor")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for CreateAccountInteractor")
        }
        
        self.authManager = authManager
        self.userManager = userManager
        self.logManager = logManager
    }
}

extension CreateAccountInteractor: CreateAccountInteractorProtocol {
    
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
