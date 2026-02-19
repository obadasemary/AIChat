//
//  ExploreUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 03.08.2025.
//

import Foundation

@MainActor
protocol ExploreUseCaseProtocol {
    var categoryRowTest: CategoryRowTestOption { get }
    var createAccountTest: Bool { get }
    
    var auth: UserAuthInfo? { get }
    
    func getFeaturedAvatars() async throws -> [AvatarModel]
    func getPopularAvatars() async throws -> [AvatarModel]
    
    func schedulePushNotificationForTheNextWeek()
    func canRequestAuthorization() async -> Bool
    func reuestAuthorization() async throws -> Bool
    
    func updateAppState(showTabBarView: Bool)
    func switchToTab(_ tab: AppTab)
    func signOut() throws
    
    func trackEvent(event: LoggableEvent)
}

@MainActor
final class ExploreUseCase {
    
    private let authManager: AuthManager
    private let userManager: UserManager
    private let avatarManager: AvatarManager
    private let logManager: LogManager
    private let pushManager: PushManager
    private let abTestManager: ABTestManager
    private let appState: AppState
    
    init(container: DependencyContainer) {
        guard let authManager = container.resolve(AuthManager.self) else {
            preconditionFailure("Failed to resolve AuthManager for ExploreUseCase")
        }
        guard let userManager = container.resolve(UserManager.self) else {
            preconditionFailure("Failed to resolve UserManager for ExploreUseCase")
        }
        guard let avatarManager = container.resolve(AvatarManager.self) else {
            preconditionFailure("Failed to resolve AvatarManager for ExploreUseCase")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for ExploreUseCase")
        }
        guard let pushManager = container.resolve(PushManager.self) else {
            preconditionFailure("Failed to resolve PushManager for ExploreUseCase")
        }
        guard let abTestManager = container.resolve(ABTestManager.self) else {
            preconditionFailure("Failed to resolve ABTestManager for ExploreUseCase")
        }
        guard let appState = container.resolve(AppState.self) else {
            preconditionFailure("Failed to resolve AppState for ExploreUseCase")
        }
        
        self.authManager = authManager
        self.userManager = userManager
        self.avatarManager = avatarManager
        self.logManager = logManager
        self.pushManager = pushManager
        self.abTestManager = abTestManager
        self.appState = appState
    }
}

extension ExploreUseCase: ExploreUseCaseProtocol {
    
    var categoryRowTest: CategoryRowTestOption {
        abTestManager.activeTests.categoryRowTest
    }
    
    var createAccountTest: Bool {
        abTestManager.activeTests.createAccountTest
    }
    
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await avatarManager.getFeaturedAvatars()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await avatarManager.getPopularAvatars()
    }
    
    func schedulePushNotificationForTheNextWeek() {
        pushManager.schedulePushNotificationForTheNextWeek()
    }
    
    func canRequestAuthorization() async -> Bool {
        await pushManager.canRequestAuthorization()
    }
    
    func reuestAuthorization() async throws -> Bool {
        try await pushManager.reuestAuthorization()
    }
    
    func updateAppState(showTabBarView: Bool) {
        appState.updateViewState(showTabBarView: showTabBarView)
    }
    
    func switchToTab(_ tab: AppTab) {
        appState.switchToTab(tab)
    }
    
    func signOut() throws {
        try authManager.signOut()
        userManager.signOut()
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
