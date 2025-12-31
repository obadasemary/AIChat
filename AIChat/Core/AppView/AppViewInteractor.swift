//
//  AppViewInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol AppViewInteractorProtocol {
    var showTabBar: Bool { get }
    var auth: UserAuthInfo? { get }
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class AppViewInteractor {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    //    private let purchaseManager: PurchaseManager
    private let appState: AppState
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        guard let authManager = container.resolve(AuthManager.self) else {
            preconditionFailure("Failed to resolve AuthManager for AppViewInteractor")
        }
        guard let userManager = container.resolve(UserManager.self) else {
            preconditionFailure("Failed to resolve UserManager for AppViewInteractor")
        }
        guard let appState = container.resolve(AppState.self) else {
            preconditionFailure("Failed to resolve AppState for AppViewInteractor")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for AppViewInteractor")
        }
        
        self.authManager = authManager
        self.userManager = userManager
        self.appState = appState
        self.logManager = logManager
    }
}

extension AppViewInteractor: AppViewInteractorProtocol {
    
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
