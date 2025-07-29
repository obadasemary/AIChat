//
//  AppViewUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
final class AppViewUseCase {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    //    private let purchaseManager: PurchaseManager
    private let appState: AppState
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
//        self.purchaseManager = container.resolve(PurchaseManager.self)!
        self.appState = container.resolve(AppState.self)!
        self.logManager = container.resolve(LogManager.self)!
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
