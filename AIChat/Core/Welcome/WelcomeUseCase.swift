//
//  WelcomeUseCase.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol WelcomeUseCaseProtocol {
    func updateAppState(showTabBarView: Bool)
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class WelcomeUseCase {
    
    private let appState: AppState
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        guard let appState = container.resolve(AppState.self) else {
            fatalError("Failed to resolve AppState for WelcomeUseCase")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            fatalError("Failed to resolve LogManager for WelcomeUseCase")
        }
        self.appState = appState
        self.logManager = logManager
    }
}

extension WelcomeUseCase: WelcomeUseCaseProtocol {
    
    func updateAppState(showTabBarView: Bool) {
        appState.updateViewState(showTabBarView: showTabBarView)
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
