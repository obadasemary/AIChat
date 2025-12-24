//
//  WelcomeInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol WelcomeInteractorProtocol {
    func updateAppState(showTabBarView: Bool)
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class WelcomeInteractor {
    
    private let appState: AppState
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        guard let appState = container.resolve(AppState.self) else {
            preconditionFailure("Failed to resolve AppState for WelcomeInteractor")
        }
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for WelcomeInteractor")
        }
        self.appState = appState
        self.logManager = logManager
    }
}

extension WelcomeInteractor: WelcomeInteractorProtocol {
    
    func updateAppState(showTabBarView: Bool) {
        appState.updateViewState(showTabBarView: showTabBarView)
    }
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
