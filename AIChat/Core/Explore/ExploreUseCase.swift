//
//  ExploreUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 03.08.2025.
//

import Foundation

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
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
        self.appState = container.resolve(AppState.self)!
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
    
    func signOut() throws {
        try authManager.signOut()
        userManager.signOut()
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
