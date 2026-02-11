//
//  OnboardingCompletedInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 29.07.2025.
//

import Foundation

@MainActor
protocol OnboardingCompletedInteractorProtocol {
    func markOnboardingCompleteForCurrentUser(profileColorHex: String) async throws
    func updateAppState(showTabBarView: Bool)
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class OnboardingCompletedInteractor {
    
    private let userManager: UserManager
    private let appState: AppState
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        guard let userManager = container.resolve(UserManager.self) else {
            preconditionFailure("Failed to resolve UserManager for OnboardingCompletedInteractor")
        }
        guard let appState = container.resolve(AppState.self) else {
            preconditionFailure("Failed to resolve AppState for OnboardingCompletedInteractor")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for OnboardingCompletedInteractor")
        }
        
        self.userManager = userManager
        self.appState = appState
        self.logManager = logManager
    }
}

extension OnboardingCompletedInteractor: OnboardingCompletedInteractorProtocol {
    
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
