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
        self.appState = container.resolve(AppState.self)!
        self.logManager = container.resolve(LogManager.self)!
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
