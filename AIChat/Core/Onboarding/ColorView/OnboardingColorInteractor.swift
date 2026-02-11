//
//  OnboardingColorInteractor.swift
//  AIChat
//
//  Created by Abdelrahman Mohamed on 28.07.2025.
//

import Foundation

@MainActor
protocol OnboardingColorInteractorProtocol {
    func trackEvent(event: any LoggableEvent)
}

@MainActor
final class OnboardingColorInteractor {
    
    private let logManager: LogManager
    
    init(container: DependencyContainer) {
        guard let logManager = container.resolve(LogManager.self) else {
            preconditionFailure("Failed to resolve LogManager for OnboardingColorInteractor")
        }
        self.logManager = logManager
    }
}

extension OnboardingColorInteractor: OnboardingColorInteractorProtocol {
    
    func trackEvent(event: any LoggableEvent) {
        logManager.trackEvent(event: event)
    }
}
