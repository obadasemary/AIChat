//
//  OnboardingCompletedUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 29.07.2025.
//

import Foundation

@MainActor
final class OnboardingCompletedUseCase {
    
    private let userManager: UserManager
    private let appState: AppState
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        self.userManager = container.resolve(UserManager.self)!
        self.appState = container.resolve(AppState.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
}

extension OnboardingCompletedUseCase: OnboardingCompletedUseCaseProtocol {
    
    func markOnboardingCompleteForCurrentUser(
        profileColorHex: String
    ) async throws {
        try await userManager
            .markOnboardingCompleteForCurrentUser(
                profileColorHex: profileColorHex
            )
    }
    
    func updateAppState(showTabBarView: Bool) {
        appState.updateViewState(showTabBarView: showTabBarView)
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
