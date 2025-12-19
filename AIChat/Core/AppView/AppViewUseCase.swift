//
//  AppViewUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol AppViewUseCaseProtocol {
    var showTabBar: Bool { get }
    var auth: UserAuthInfo? { get }
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class AppViewUseCase {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    //    private let purchaseManager: PurchaseManager
    private let appState: AppState
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        guard let authManager = container.resolve(AuthManager.self) else {
            preconditionFailure("Failed to resolve AuthManager for AppViewUseCase")
        }
        guard let userManager = container.resolve(UserManager.self) else {
            preconditionFailure("Failed to resolve UserManager for AppViewUseCase")
        }
        guard let appState = container.resolve(AppState.self) else {
            preconditionFailure("Failed to resolve AppState for AppViewUseCase")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for AppViewUseCase")
        }
        
        self.authManager = authManager
        self.userManager = userManager
        self.appState = appState
        self.logManager = logManager
    }
}

extension AppViewUseCase: AppViewUseCaseProtocol {
    
    var showTabBar: Bool {
        appState.showTabBar
    }
    
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.logIn(auth: auth, isNewUser: isNewUser)
//        try await purchaseManager
    }
    
    func signInAnonymously() async throws -> (
        user: UserAuthInfo,
        isNewUser: Bool
    ) {
        try await authManager.signInAnonymously()
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
